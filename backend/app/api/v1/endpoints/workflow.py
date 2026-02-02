"""
Workflow API Endpoints

Handles order state transitions, workflow queries, and orchestration actions
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel

from app.core.database import get_db
from app.core.security import get_current_active_user, require_role
from app.models.user import User, UserRole
from app.models.order import Order, OrderStatus
from app.services.workflow_service import WorkflowService, TextileOrchestratorService

router = APIRouter()


# Request/Response Models
class StatusUpdateRequest(BaseModel):
    new_status: str
    notes: Optional[str] = None
    metadata: Optional[dict] = None


class StatusUpdateResponse(BaseModel):
    order_id: int
    old_status: str
    new_status: str
    updated_at: str
    message: str


class TransitionInfo(BaseModel):
    status: str
    can_transition: bool
    allowed_roles: List[str]


class OrderTimelineEntry(BaseModel):
    status: str
    timestamp: Optional[str]
    is_current: bool


class AssignVendorRequest(BaseModel):
    vendor_id: int
    cost: float
    details: Optional[dict] = None


class AcceptOrderRequest(BaseModel):
    proposed_cost: float
    estimated_days: int


# Endpoints
@router.post("/orders/{order_id}/update-status", response_model=StatusUpdateResponse)
async def update_order_status(
    order_id: int,
    request: StatusUpdateRequest,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """
    Update order status with validation and triggers
    
    - Validates state transition is allowed
    - Checks user role has permission
    - Triggers notifications, logistics, payments as needed
    """
    workflow = WorkflowService(db)
    
    # Get old status for response
    order = db.query(Order).filter(Order.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    old_status = order.status
    
    try:
        new_status = OrderStatus(request.new_status)
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status: {request.new_status}. Valid statuses: {[s.value for s in OrderStatus]}"
        )
    
    updated_order = workflow.update_order_status(
        order_id=order_id,
        new_status=new_status,
        user=current_user,
        notes=request.notes,
        metadata=request.metadata
    )
    
    return StatusUpdateResponse(
        order_id=order_id,
        old_status=old_status.value,
        new_status=updated_order.status.value,
        updated_at=updated_order.updated_at.isoformat() if updated_order.updated_at else "",
        message=f"Order status updated successfully"
    )


@router.get("/orders/{order_id}/available-transitions", response_model=List[TransitionInfo])
async def get_available_transitions(
    order_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """
    Get list of valid status transitions for current user
    
    Returns which statuses the user can transition the order to,
    based on current status and user's role permissions
    """
    workflow = WorkflowService(db)
    return workflow.get_available_transitions(order_id, current_user)


@router.get("/orders/{order_id}/timeline", response_model=List[OrderTimelineEntry])
async def get_order_timeline(
    order_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """
    Get complete status timeline for an order
    
    Shows all status changes with timestamps
    """
    workflow = WorkflowService(db)
    return workflow.get_order_timeline(order_id)


@router.get("/orders/{order_id}/cascade")
async def get_order_cascade(
    order_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """
    Get the complete supply chain cascade for an order
    
    Shows all sub-orders, vendors, and their statuses in sequence
    """
    # Check if user has access to this order
    order = db.query(Order).filter(Order.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    # Buyer can only see their own orders
    if current_user.role == UserRole.BUYER and order.buyer_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="Not authorized to view this order")
    
    workflow = WorkflowService(db)
    # Create a mock textile service to use get_order_cascade
    # In production, this would be refactored
    from app.services.workflow_service import TextileOrchestratorService
    textile_service = TextileOrchestratorService(db, current_user)
    return textile_service.get_order_cascade(order_id)


# Textile Orchestrator Endpoints
@router.post("/textile/orders/{order_id}/accept")
async def textile_accept_order(
    order_id: int,
    request: AcceptOrderRequest,
    current_user: User = Depends(require_role([UserRole.TEXTILE])),
    db: Session = Depends(get_db)
):
    """
    Textile accepts an order and becomes the orchestrator
    
    This is a key action that starts the production workflow
    """
    textile_service = TextileOrchestratorService(db, current_user)
    order = textile_service.accept_order(
        order_id=order_id,
        proposed_cost=request.proposed_cost,
        estimated_days=request.estimated_days
    )
    return {
        "message": "Order accepted successfully",
        "order_id": order.order_id,
        "status": order.status.value,
        "estimated_delivery": order.estimated_delivery.isoformat() if order.estimated_delivery else None
    }


@router.post("/textile/orders/{order_id}/assign-fabric-seller")
async def assign_fabric_seller(
    order_id: int,
    request: AssignVendorRequest,
    current_user: User = Depends(require_role([UserRole.TEXTILE])),
    db: Session = Depends(get_db)
):
    """
    Assign a fabric seller to source fabric for this order
    """
    textile_service = TextileOrchestratorService(db, current_user)
    sub_order = textile_service.assign_fabric_seller(
        order_id=order_id,
        fabric_seller_id=request.vendor_id,
        fabric_details={"cost": request.cost, **(request.details or {})}
    )
    return {
        "message": "Fabric seller assigned",
        "sub_order_id": sub_order.sub_order_id
    }


@router.post("/textile/orders/{order_id}/assign-printing-unit")
async def assign_printing_unit(
    order_id: int,
    request: AssignVendorRequest,
    current_user: User = Depends(require_role([UserRole.TEXTILE])),
    db: Session = Depends(get_db)
):
    """
    Assign a printing unit for the order
    """
    textile_service = TextileOrchestratorService(db, current_user)
    sub_order = textile_service.assign_printing_unit(
        order_id=order_id,
        printing_unit_id=request.vendor_id,
        printing_details={"cost": request.cost, **(request.details or {})}
    )
    return {
        "message": "Printing unit assigned",
        "sub_order_id": sub_order.sub_order_id
    }


@router.post("/textile/orders/{order_id}/assign-stitching-unit")
async def assign_stitching_unit(
    order_id: int,
    request: AssignVendorRequest,
    current_user: User = Depends(require_role([UserRole.TEXTILE])),
    db: Session = Depends(get_db)
):
    """
    Assign a stitching unit for the order
    """
    textile_service = TextileOrchestratorService(db, current_user)
    sub_order = textile_service.assign_stitching_unit(
        order_id=order_id,
        stitching_unit_id=request.vendor_id,
        stitching_details={"cost": request.cost, **(request.details or {})}
    )
    return {
        "message": "Stitching unit assigned",
        "sub_order_id": sub_order.sub_order_id
    }


# Dashboard endpoints for each role
@router.get("/dashboard/my-orders")
async def get_role_dashboard_orders(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """
    Get orders relevant to the current user's role
    
    - Buyers see their own orders
    - Textiles see orders they're orchestrating
    - Vendors see sub-orders assigned to them
    - Logistics see shipments assigned to them
    """
    from app.models.order import SubOrder
    from app.models.shipment import Shipment
    
    if current_user.role == UserRole.BUYER:
        orders = db.query(Order).filter(
            Order.buyer_id == current_user.user_id
        ).order_by(Order.created_at.desc()).all()
        
        return [{
            "order_id": o.order_id,
            "status": o.status.value,
            "fabric_type": o.fabric_type,
            "quantity": o.quantity_meters,
            "total_cost": o.total_cost,
            "created_at": o.created_at.isoformat() if o.created_at else None,
            "estimated_delivery": o.estimated_delivery.isoformat() if o.estimated_delivery else None
        } for o in orders]
    
    elif current_user.role in [UserRole.TEXTILE, UserRole.FABRIC_SELLER, 
                                UserRole.PRINTING_UNIT, UserRole.STITCHING_UNIT,
                                UserRole.WEAVER, UserRole.YARN_MANUFACTURER]:
        # Get sub-orders assigned to this vendor
        sub_orders = db.query(SubOrder).filter(
            SubOrder.assigned_vendor_id == current_user.user_id
        ).order_by(SubOrder.offered_at.desc()).all()
        
        result = []
        for so in sub_orders:
            order = db.query(Order).filter(Order.order_id == so.parent_order_id).first()
            result.append({
                "sub_order_id": so.sub_order_id,
                "order_id": so.parent_order_id,
                "order_status": order.status.value if order else None,
                "task_type": so.task_type.value if hasattr(so.task_type, 'value') else so.task_type,
                "status": so.status.value,
                "agreed_cost": so.agreed_cost,
                "offered_at": so.offered_at.isoformat() if so.offered_at else None
            })
        return result
    
    elif current_user.role == UserRole.LOGISTICS:
        # Get shipments assigned to this provider
        shipments = db.query(Shipment).filter(
            Shipment.logistics_provider_id == current_user.user_id
        ).order_by(Shipment.created_at.desc()).all()
        
        return [{
            "shipment_id": s.shipment_id,
            "tracking_number": s.tracking_number,
            "status": s.current_status.value,
            "pickup_location": s.pickup_location,
            "drop_location": s.drop_location,
            "estimated_delivery": s.estimated_delivery.isoformat() if s.estimated_delivery else None
        } for s in shipments]
    
    elif current_user.role == UserRole.ADMIN:
        # Admin sees all orders
        orders = db.query(Order).order_by(Order.created_at.desc()).limit(100).all()
        return [{
            "order_id": o.order_id,
            "buyer_id": o.buyer_id,
            "status": o.status.value,
            "fabric_type": o.fabric_type,
            "total_cost": o.total_cost,
            "created_at": o.created_at.isoformat() if o.created_at else None
        } for o in orders]
    
    return []
