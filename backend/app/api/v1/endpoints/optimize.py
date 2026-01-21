from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.services.optimization_service import OptimizationEngine
from app.core.security import get_current_active_user
from app.models.user import User

router = APIRouter()


@router.post("/find-vendors")
async def find_vendors(
    material_type: str,
    quantity_required: float,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Find best vendors for specific material"""
    
    optimizer = OptimizationEngine(db)
    
    vendors = optimizer.find_best_material_vendors(
        material_type=material_type,
        quantity_required=quantity_required,
        buyer_location=current_user.location_data
    )
    
    return {
        "success": True,
        "material_type": material_type,
        "vendors_found": len(vendors),
        "vendors": vendors[:10]  # Top 10
    }


@router.post("/route")
async def calculate_route(
    order_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Calculate optimal supply chain route"""
    
    optimizer = OptimizationEngine(db)
    
    try:
        supply_chain = optimizer.create_optimized_supply_chain(order_id)
        return {
            "success": True,
            "supply_chain": supply_chain
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
