from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import time

from app.core.database import get_db
from app.core.security import get_current_active_user
from app.models.user import User
from app.schemas.ai import (
    DesignGenerateRequest,
    DesignGenerateResponse,
    BOMCalculateRequest,
    BOMCalculateResponse,
    BOMItem
)
from app.services.ai_service import AIDesignService

router = APIRouter()


@router.post("/generate-design", response_model=DesignGenerateResponse)
async def generate_fabric_design(
    request: DesignGenerateRequest,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Generate AI fabric design from text prompt"""
    
    start_time = time.time()
    
    try:
        # Use Stable Diffusion for now (more reliable for image generation)
        image_url = await AIDesignService.generate_design_stable_diffusion(request.prompt)
        
        generation_time = time.time() - start_time
        
        return DesignGenerateResponse(
            success=True,
            image_url=image_url,
            prompt_used=request.prompt,
            generation_time=round(generation_time, 2)
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Design generation failed: {str(e)}")


@router.post("/calculate-bom", response_model=BOMCalculateResponse)
async def calculate_bill_of_materials(
    request: BOMCalculateRequest,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Calculate Bill of Materials for fabric order"""
    
    try:
        bom_items = await AIDesignService.calculate_bom(
            fabric_type=request.fabric_type,
            quantity_meters=request.quantity_meters,
            thread_count=request.thread_count,
            gsm=request.gsm
        )
        
        # Convert to BOMItem schema
        bom_response_items = [BOMItem(**item) for item in bom_items]
        
        total_cost = sum(item.estimated_cost for item in bom_response_items)
        
        return BOMCalculateResponse(
            success=True,
            bom_items=bom_response_items,
            total_estimated_cost=round(total_cost, 2),
            fabric_type=request.fabric_type,
            quantity_meters=request.quantity_meters
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"BOM calculation failed: {str(e)}")
