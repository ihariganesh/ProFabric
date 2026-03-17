from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional

from app.core.database import get_db
from app.services.optimization_service import OptimizationEngine
from app.core.security import get_current_active_user
from app.models.user import User

router = APIRouter()


@router.post("/find-vendors")
async def find_vendors(
    material_type: str,
    quantity_required: float,
    use_sustainability: bool = False,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Find best vendors for specific material with EcoFlow"""
    
    optimizer = OptimizationEngine(db, use_sustainability=use_sustainability)
    
    vendors = optimizer.find_best_material_vendors(
        material_type=material_type,
        quantity_required=quantity_required,
        buyer_location=current_user.location_data
    )
    
    return {
        "success": True,
        "material_type": material_type,
        "eco_flow_active": use_sustainability,
        "vendors_found": len(vendors),
        "vendors": vendors[:10]  # Top 10
    }


@router.post("/route")
async def calculate_route(
    order_id: int,
    use_sustainability: bool = False,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Calculate optimal supply chain route with EcoFlow and FabricSim"""
    
    optimizer = OptimizationEngine(db, use_sustainability=use_sustainability)
    
    try:
        supply_chain = optimizer.create_optimized_supply_chain(order_id)
        
        # FabricSim Integration
        simulation = optimizer.simulate_run(supply_chain)
        
        return {
            "success": True,
            "eco_flow_active": use_sustainability,
            "supply_chain": supply_chain,
            "fabric_sim": simulation,
            "risk_radar": {
                "active_alerts": 2,
                "status": "Warning",
                "summary": "Port congestion may delay Step 3"
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
