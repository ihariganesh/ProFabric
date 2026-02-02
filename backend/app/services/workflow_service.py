"""
Workflow Service - Order State Machine & Orchestration Engine

This service manages:
1. Order state transitions with validation
2. Role-based permission checks for state changes
3. Automatic triggers (notifications, logistics, payments)
4. Cascade effects on sub-orders and related entities
"""

from typing import Optional, List, Dict, Any, Tuple
from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.models.order import Order, OrderStatus, SubOrder, SubOrderStatus, ORDER_STATE_TRANSITIONS
from app.models.user import User, UserRole
from app.models.notification import Notification
from app.models.shipment import Shipment, ShipmentStatus


# Role permissions for status updates
STATUS_ROLE_PERMISSIONS: Dict[OrderStatus, List[UserRole]] = {
    # Buyer can only update sample approval/rejection
    OrderStatus.SAMPLE_APPROVED: [UserRole.BUYER],
    OrderStatus.SAMPLE_REJECTED: [UserRole.BUYER],
    
    # Textile (Orchestrator) manages most production states
    OrderStatus.DESIGN_PROCESSING: [UserRole.TEXTILE, UserRole.ADMIN],
    OrderStatus.DESIGN_READY: [UserRole.TEXTILE, UserRole.ADMIN],
    OrderStatus.TEXTILE_SELECTED: [UserRole.BUYER],  # Buyer selects textile
    OrderStatus.SAMPLE_REQUESTED: [UserRole.BUYER],
    OrderStatus.SAMPLE_IN_PRODUCTION: [UserRole.TEXTILE],
    OrderStatus.SAMPLE_SENT: [UserRole.TEXTILE],
    OrderStatus.SAMPLE_DELIVERED: [UserRole.LOGISTICS],
    OrderStatus.FABRIC_SOURCING: [UserRole.TEXTILE],
    OrderStatus.FABRIC_SOURCED: [UserRole.TEXTILE, UserRole.FABRIC_SELLER],
    OrderStatus.PRINTING_PENDING: [UserRole.TEXTILE],
    OrderStatus.PRINTING_IN_PROGRESS: [UserRole.PRINTING_UNIT],
    OrderStatus.PRINTING_COMPLETED: [UserRole.PRINTING_UNIT],
    OrderStatus.STITCHING_PENDING: [UserRole.TEXTILE],
    OrderStatus.STITCHING_IN_PROGRESS: [UserRole.STITCHING_UNIT],
    OrderStatus.STITCHING_COMPLETED: [UserRole.STITCHING_UNIT],
    OrderStatus.QUALITY_CHECK_PENDING: [UserRole.TEXTILE],
    OrderStatus.QUALITY_CHECK_IN_PROGRESS: [UserRole.TEXTILE],
    OrderStatus.QUALITY_APPROVED: [UserRole.TEXTILE],
    OrderStatus.QUALITY_REJECTED: [UserRole.TEXTILE],
    OrderStatus.PACKAGING: [UserRole.STITCHING_UNIT, UserRole.TEXTILE],
    OrderStatus.PACKAGING_COMPLETED: [UserRole.STITCHING_UNIT, UserRole.TEXTILE],
    OrderStatus.READY_FOR_SHIPMENT: [UserRole.TEXTILE],
    
    # Logistics handles shipping states
    OrderStatus.PICKUP_SCHEDULED: [UserRole.LOGISTICS],
    OrderStatus.PICKED_UP: [UserRole.LOGISTICS],
    OrderStatus.IN_TRANSIT: [UserRole.LOGISTICS],
    OrderStatus.AT_HUB: [UserRole.LOGISTICS],
    OrderStatus.OUT_FOR_DELIVERY: [UserRole.LOGISTICS],
    OrderStatus.DELIVERED: [UserRole.LOGISTICS, UserRole.BUYER],
    
    # Exception states
    OrderStatus.ON_HOLD: [UserRole.TEXTILE, UserRole.ADMIN],
    OrderStatus.CANCELLED: [UserRole.BUYER, UserRole.TEXTILE, UserRole.ADMIN],
    OrderStatus.DISPUTED: [UserRole.BUYER, UserRole.TEXTILE, UserRole.ADMIN],
    OrderStatus.REFUNDED: [UserRole.ADMIN],
}


class WorkflowService:
    """
    Core workflow orchestration engine for order management
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    def validate_transition(
        self, 
        current_status: OrderStatus, 
        new_status: OrderStatus
    ) -> Tuple[bool, str]:
        """
        Validate if a state transition is allowed
        Returns (is_valid, error_message)
        """
        if current_status == new_status:
            return False, f"Order is already in {current_status.value} status"
        
        allowed_transitions = ORDER_STATE_TRANSITIONS.get(current_status, [])
        
        if new_status not in allowed_transitions:
            return False, (
                f"Invalid transition from {current_status.value} to {new_status.value}. "
                f"Allowed transitions: {[s.value for s in allowed_transitions]}"
            )
        
        return True, ""
    
    def check_role_permission(
        self, 
        user: User, 
        target_status: OrderStatus,
        order: Order
    ) -> Tuple[bool, str]:
        """
        Check if user's role allows updating to target status
        """
        allowed_roles = STATUS_ROLE_PERMISSIONS.get(target_status, [])
        
        # Admin can do anything
        if user.role == UserRole.ADMIN:
            return True, ""
        
        # Check if user's role is allowed
        if user.role not in allowed_roles:
            return False, (
                f"Role {user.role.value} is not authorized to update order to {target_status.value}. "
                f"Allowed roles: {[r.value for r in allowed_roles]}"
            )
        
        # Additional checks based on order relationship
        # Buyer must be the order owner
        if user.role == UserRole.BUYER and order.buyer_id != user.user_id:
            return False, "You can only update your own orders"
        
        # Textile must be assigned to this order
        if user.role == UserRole.TEXTILE:
            # Check if this textile is the assigned orchestrator
            assigned = self._is_user_assigned_to_order(user.user_id, order.order_id)
            if not assigned:
                return False, "You are not assigned as the orchestrator for this order"
        
        return True, ""
    
    def _is_user_assigned_to_order(self, user_id: int, order_id: int) -> bool:
        """Check if a vendor/textile is assigned to an order via sub-orders"""
        sub_order = self.db.query(SubOrder).filter(
            SubOrder.parent_order_id == order_id,
            SubOrder.assigned_vendor_id == user_id
        ).first()
        return sub_order is not None
    
    def update_order_status(
        self,
        order_id: int,
        new_status: OrderStatus,
        user: User,
        notes: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Order:
        """
        Main method to update order status with full validation and triggers
        """
        # Fetch order
        order = self.db.query(Order).filter(Order.order_id == order_id).first()
        if not order:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Order {order_id} not found"
            )
        
        # Validate transition
        is_valid, error_msg = self.validate_transition(order.status, new_status)
        if not is_valid:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=error_msg
            )
        
        # Check permissions
        has_permission, perm_error = self.check_role_permission(user, new_status, order)
        if not has_permission:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=perm_error
            )
        
        # Store old status for triggers
        old_status = order.status
        
        # Update order
        order.status = new_status
        order.updated_at = datetime.utcnow()
        
        # Execute post-transition triggers
        self._execute_triggers(order, old_status, new_status, user, metadata)
        
        # Add status history (optional: create OrderStatusHistory table)
        self._log_status_change(order, old_status, new_status, user, notes)
        
        self.db.commit()
        self.db.refresh(order)
        
        return order
    
    def _execute_triggers(
        self,
        order: Order,
        old_status: OrderStatus,
        new_status: OrderStatus,
        user: User,
        metadata: Optional[Dict[str, Any]] = None
    ):
        """
        Execute automatic actions based on status transitions
        """
        # Notify relevant parties
        self._send_status_notification(order, old_status, new_status)
        
        # Trigger logistics when ready for shipment
        if new_status == OrderStatus.READY_FOR_SHIPMENT:
            self._trigger_logistics_request(order)
        
        # Release payment milestones
        if new_status in [
            OrderStatus.SAMPLE_APPROVED,
            OrderStatus.PRINTING_COMPLETED,
            OrderStatus.DELIVERED
        ]:
            self._trigger_milestone_payment(order, new_status)
        
        # Handle cancellation
        if new_status == OrderStatus.CANCELLED:
            self._handle_cancellation(order)
        
        # Update estimated delivery based on status
        if new_status == OrderStatus.FABRIC_SOURCED:
            self._update_delivery_estimate(order)
    
    def _send_status_notification(
        self,
        order: Order,
        old_status: OrderStatus,
        new_status: OrderStatus
    ):
        """Send notifications to relevant parties about status change"""
        # Notify buyer
        notification = Notification(
            user_id=order.buyer_id,
            title=f"Order #{order.order_id} Status Update",
            message=f"Your order status changed from {old_status.value} to {new_status.value}",
            notification_type="order_status",
            related_order_id=order.order_id,
            is_read=False
        )
        self.db.add(notification)
        
        # Notify assigned vendors based on new status
        if new_status == OrderStatus.PRINTING_PENDING:
            self._notify_printing_units(order)
        elif new_status == OrderStatus.STITCHING_PENDING:
            self._notify_stitching_units(order)
        elif new_status == OrderStatus.READY_FOR_SHIPMENT:
            self._notify_logistics_providers(order)
    
    def _trigger_logistics_request(self, order: Order):
        """Auto-create logistics request when order is ready for shipment"""
        # Find the main sub-order that needs shipping
        sub_order = self.db.query(SubOrder).filter(
            SubOrder.parent_order_id == order.order_id,
            SubOrder.status == SubOrderStatus.COMPLETED
        ).order_by(SubOrder.sequence_order.desc()).first()
        
        if sub_order:
            # Create pending shipment
            shipment = Shipment(
                related_sub_order_id=sub_order.sub_order_id,
                pickup_location="To be assigned",  # Will be filled by logistics
                drop_location=order.buyer.location_data.get('address', '') if order.buyer.location_data else '',
                current_status=ShipmentStatus.PENDING_PICKUP
            )
            self.db.add(shipment)
    
    def _trigger_milestone_payment(self, order: Order, milestone_status: OrderStatus):
        """Trigger milestone payment release"""
        # This would integrate with payment service
        # For now, just log the milestone
        pass
    
    def _handle_cancellation(self, order: Order):
        """Handle order cancellation - update all sub-orders"""
        for sub_order in order.sub_orders:
            if sub_order.status not in [SubOrderStatus.COMPLETED, SubOrderStatus.CANCELLED]:
                sub_order.status = SubOrderStatus.CANCELLED
    
    def _update_delivery_estimate(self, order: Order):
        """Calculate and update estimated delivery date"""
        from datetime import timedelta
        # Simple estimate: 7-14 days from fabric sourced
        order.estimated_delivery = datetime.utcnow() + timedelta(days=10)
    
    def _notify_printing_units(self, order: Order):
        """Notify available printing units about new job"""
        printing_units = self.db.query(User).filter(
            User.role == UserRole.PRINTING_UNIT,
            User.is_active == True
        ).all()
        
        for unit in printing_units:
            notification = Notification(
                user_id=unit.user_id,
                title="New Printing Job Available",
                message=f"Order #{order.order_id} needs printing services",
                notification_type="job_available",
                related_order_id=order.order_id
            )
            self.db.add(notification)
    
    def _notify_stitching_units(self, order: Order):
        """Notify available stitching units about new job"""
        stitching_units = self.db.query(User).filter(
            User.role == UserRole.STITCHING_UNIT,
            User.is_active == True
        ).all()
        
        for unit in stitching_units:
            notification = Notification(
                user_id=unit.user_id,
                title="New Stitching Job Available",
                message=f"Order #{order.order_id} needs stitching services",
                notification_type="job_available",
                related_order_id=order.order_id
            )
            self.db.add(notification)
    
    def _notify_logistics_providers(self, order: Order):
        """Notify available logistics providers about pickup"""
        logistics = self.db.query(User).filter(
            User.role == UserRole.LOGISTICS,
            User.is_active == True
        ).all()
        
        for provider in logistics:
            notification = Notification(
                user_id=provider.user_id,
                title="New Shipment Ready for Pickup",
                message=f"Order #{order.order_id} is ready for shipment",
                notification_type="shipment_ready",
                related_order_id=order.order_id
            )
            self.db.add(notification)
    
    def _log_status_change(
        self,
        order: Order,
        old_status: OrderStatus,
        new_status: OrderStatus,
        user: User,
        notes: Optional[str]
    ):
        """Log status change for audit trail (could be separate table)"""
        # For now, we'll store in order's JSON field or create audit log
        pass
    
    def get_order_timeline(self, order_id: int) -> List[Dict[str, Any]]:
        """Get complete timeline of order status changes"""
        # This would query OrderStatusHistory table
        # For now, return current status
        order = self.db.query(Order).filter(Order.order_id == order_id).first()
        if not order:
            return []
        
        return [
            {
                "status": order.status.value,
                "timestamp": order.updated_at.isoformat() if order.updated_at else None,
                "is_current": True
            }
        ]
    
    def get_available_transitions(
        self, 
        order_id: int, 
        user: User
    ) -> List[Dict[str, Any]]:
        """Get list of valid next statuses user can transition to"""
        order = self.db.query(Order).filter(Order.order_id == order_id).first()
        if not order:
            return []
        
        allowed_transitions = ORDER_STATE_TRANSITIONS.get(order.status, [])
        available = []
        
        for next_status in allowed_transitions:
            has_permission, _ = self.check_role_permission(user, next_status, order)
            available.append({
                "status": next_status.value,
                "can_transition": has_permission,
                "allowed_roles": [r.value for r in STATUS_ROLE_PERMISSIONS.get(next_status, [])]
            })
        
        return available


class TextileOrchestratorService:
    """
    Specialized service for Textile role - the core orchestrator
    Manages the entire production workflow
    """
    
    def __init__(self, db: Session, textile_user: User):
        self.db = db
        self.textile = textile_user
        self.workflow = WorkflowService(db)
    
    def accept_order(self, order_id: int, proposed_cost: float, estimated_days: int) -> Order:
        """Textile accepts an order and becomes the orchestrator"""
        order = self.db.query(Order).filter(Order.order_id == order_id).first()
        if not order:
            raise HTTPException(status_code=404, detail="Order not found")
        
        # Create orchestrator sub-order
        orchestrator_task = SubOrder(
            parent_order_id=order_id,
            assigned_vendor_id=self.textile.user_id,
            task_type="Orchestration",
            task_description="Main textile orchestrating entire order",
            agreed_cost=proposed_cost,
            status=SubOrderStatus.ACCEPTED,
            sequence_order=0,
            accepted_at=datetime.utcnow()
        )
        self.db.add(orchestrator_task)
        
        # Update order
        order.status = OrderStatus.TEXTILE_SELECTED
        order.total_cost = proposed_cost
        from datetime import timedelta
        order.estimated_delivery = datetime.utcnow() + timedelta(days=estimated_days)
        
        self.db.commit()
        return order
    
    def assign_fabric_seller(
        self, 
        order_id: int, 
        fabric_seller_id: int,
        fabric_details: Dict[str, Any]
    ) -> SubOrder:
        """Assign a fabric seller to source fabric for this order"""
        sub_order = SubOrder(
            parent_order_id=order_id,
            assigned_vendor_id=fabric_seller_id,
            task_type="Supply_Material",
            task_description=f"Source fabric: {fabric_details.get('fabric_type', 'as per order')}",
            agreed_cost=fabric_details.get('cost', 0),
            status=SubOrderStatus.OFFERED,
            sequence_order=1
        )
        self.db.add(sub_order)
        self.db.commit()
        return sub_order
    
    def assign_printing_unit(
        self,
        order_id: int,
        printing_unit_id: int,
        printing_details: Dict[str, Any]
    ) -> SubOrder:
        """Assign a printing unit for the order"""
        sub_order = SubOrder(
            parent_order_id=order_id,
            assigned_vendor_id=printing_unit_id,
            task_type="Dyeing",  # or create new PRINTING type
            task_description=f"Print design: {printing_details.get('design_id', 'custom')}",
            agreed_cost=printing_details.get('cost', 0),
            status=SubOrderStatus.OFFERED,
            sequence_order=2,
            dependencies=[1]  # Depends on fabric sourcing
        )
        self.db.add(sub_order)
        self.db.commit()
        return sub_order
    
    def assign_stitching_unit(
        self,
        order_id: int,
        stitching_unit_id: int,
        stitching_details: Dict[str, Any]
    ) -> SubOrder:
        """Assign a stitching unit for the order"""
        sub_order = SubOrder(
            parent_order_id=order_id,
            assigned_vendor_id=stitching_unit_id,
            task_type="Packaging",  # or create new STITCHING type
            task_description=f"Stitch product: {stitching_details.get('garment_type', 'as per design')}",
            agreed_cost=stitching_details.get('cost', 0),
            status=SubOrderStatus.OFFERED,
            sequence_order=3,
            dependencies=[2]  # Depends on printing
        )
        self.db.add(sub_order)
        self.db.commit()
        return sub_order
    
    def get_order_cascade(self, order_id: int) -> Dict[str, Any]:
        """Get complete supply chain cascade for an order"""
        order = self.db.query(Order).filter(Order.order_id == order_id).first()
        if not order:
            return {}
        
        sub_orders = self.db.query(SubOrder).filter(
            SubOrder.parent_order_id == order_id
        ).order_by(SubOrder.sequence_order).all()
        
        cascade = {
            "order_id": order_id,
            "status": order.status.value,
            "stages": []
        }
        
        for so in sub_orders:
            vendor = self.db.query(User).filter(User.user_id == so.assigned_vendor_id).first()
            cascade["stages"].append({
                "sub_order_id": so.sub_order_id,
                "task": so.task_type.value if hasattr(so.task_type, 'value') else so.task_type,
                "vendor": vendor.name if vendor else "Unassigned",
                "vendor_role": vendor.role.value if vendor else None,
                "status": so.status.value,
                "cost": so.agreed_cost,
                "dependencies": so.dependencies
            })
        
        return cascade
