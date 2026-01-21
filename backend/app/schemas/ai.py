from pydantic import BaseModel, Field
from typing import Optional, List


class DesignGenerateRequest(BaseModel):
    prompt: str = Field(..., min_length=10, max_length=1000, 
                        description="Text description of desired fabric design")
    fabric_type: str = Field(..., description="Type of fabric (Cotton, Silk, Polyester)")
    style: Optional[str] = Field("modern", description="Design style preference")


class DesignGenerateResponse(BaseModel):
    success: bool
    image_url: str
    prompt_used: str
    generation_time: float


class BOMCalculateRequest(BaseModel):
    fabric_type: str
    quantity_meters: int = Field(..., gt=0)
    thread_count: int = Field(..., gt=0)
    gsm: int = Field(..., gt=0)


class BOMItem(BaseModel):
    material_name: str
    material_type: str
    quantity_required: float
    unit: str
    estimated_cost: float


class BOMCalculateResponse(BaseModel):
    success: bool
    bom_items: List[BOMItem]
    total_estimated_cost: float
    fabric_type: str
    quantity_meters: int
