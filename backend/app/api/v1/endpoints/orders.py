from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta

from app.core.database import get_db
from app.core.security import get_current_active_user, require_role
from app.models.user import User
from app.models.order import Order, BillOfMaterial, SubOrder, OrderStatus
from app.schemas.order import OrderCreate, OrderResponse, OrderDetailResponse, BOMItemResponse
from app.services.ai_service import AIDesignService
from app.services.optimization_service import OptimizationEngine

router = APIRouter()


@router.post("/", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(
    order_data: OrderCreate,
    current_user: User = Depends(require_role(["Buyer"])),
    db: Session = Depends(get_db)
):
    """Create a new fabric order"""
    
    # Create order
    new_order = Order(
        buyer_id=current_user.user_id,
        design_prompt=order_data.design_prompt,
        fabric_type=order_data.fabric_type,
        quantity_meters=order_data.quantity_meters,
        thread_count=order_data.thread_count,
        gsm=order_data.gsm,
        status=OrderStatus.PENDING
    )
    
    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    
    # Generate AI design (async in background in production)
    try:
        image_url = await AIDesignService.generate_design_stable_diffusion(
            order_data.design_prompt
        )
        new_order.generated_image_url = image_url
    except:
        pass  # Continue even if design generation fails
    
    # Calculate BOM
    bom_items = await AIDesignService.calculate_bom(
        fabric_type=order_data.fabric_type,
        quantity_meters=order_data.quantity_meters,
        thread_count=order_data.thread_count or 40,
        gsm=order_data.gsm or 150
    )
    
    # Save BOM to database
    for bom_item in bom_items:
        bom_entry = BillOfMaterial(
            order_id=new_order.order_id,
            **bom_item
        )
        db.add(bom_entry)
    
    # Update order status
    new_order.status = OrderStatus.ANALYZING
    
    db.commit()
    db.refresh(new_order)
    
    return new_order


@router.get("/my-orders", response_model=List[OrderResponse])
async def get_my_orders(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get all orders for current user"""
    
    if current_user.role == "Buyer":
        orders = db.query(Order).filter(Order.buyer_id == current_user.user_id).all()
    else:
        # For vendors, get orders they're involved in via sub_orders
        orders = db.query(Order).join(SubOrder).filter(
            SubOrder.assigned_vendor_id == current_user.user_id
        ).distinct().all()
    
    return orders


@router.get("/{order_id}", response_model=OrderDetailResponse)
async def get_order_detail(
    order_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get detailed order information"""
    
    order = db.query(Order).filter(Order.order_id == order_id).first()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    # Check access rights
    if current_user.role == "Buyer" and order.buyer_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    # Get BOM and SubOrders
    bom_items = db.query(BillOfMaterial).filter(
        BillOfMaterial.order_id == order_id
    ).all()
    
    sub_orders = db.query(SubOrder).filter(
        SubOrder.parent_order_id == order_id
    ).order_by(SubOrder.sequence_order).all()
    
    return {
        **order.__dict__,
        "bill_of_materials": bom_items,
        "sub_orders": sub_orders
    }


@router.post("/{order_id}/optimize")
async def optimize_order(
    order_id: int,
    use_sustainability: bool = False,
    current_user: User = Depends(require_role(["Buyer"])),
    db: Session = Depends(get_db)
):
    """Run optimization engine to find best supply chain with EcoFlow"""
    
    order = db.query(Order).filter(Order.order_id == order_id).first()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    if order.buyer_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    # Run optimization
    optimizer = OptimizationEngine(db, use_sustainability=use_sustainability)
    supply_chain = optimizer.create_optimized_supply_chain(order_id)
    
    # FabricSim Integration
    simulation = optimizer.simulate_run(supply_chain)
    
    # Create sub-orders from optimization results
    for so_data in supply_chain["sub_orders"]:
        sub_order = SubOrder(
            parent_order_id=order_id,
            assigned_vendor_id=so_data["vendor"]["vendor_id"],
            task_type=so_data["task_type"],
            task_description=f"{so_data['vendor'].get('service_name') or so_data['vendor'].get('product_name')}",
            agreed_cost=so_data["estimated_cost"],
            sequence_order=so_data["sequence"]
        )
        db.add(sub_order)
    
    # Update order
    order.total_cost = supply_chain["total_estimated_cost"]
    order.optimization_score = supply_chain["optimization_score"]
    order.status = OrderStatus.BIDDING
    order.estimated_delivery = datetime.utcnow() + timedelta(days=supply_chain["total_estimated_days"])
    
    db.commit()
    
    return {
        "message": "Optimization completed successfully",
        "eco_flow_active": use_sustainability,
        "supply_chain": supply_chain,
        "fabric_sim": simulation,
        "risk_radar": {
            "status": "Healthy",
            "active_alerts": 0
        }
    }
