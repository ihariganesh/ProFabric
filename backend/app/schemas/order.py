from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class OrderCreate(BaseModel):
    design_prompt: str = Field(..., min_length=10, max_length=1000)
    fabric_type: str = Field(..., min_length=2, max_length=100)
    quantity_meters: int = Field(..., gt=0)
    thread_count: Optional[int] = Field(None, gt=0)
    gsm: Optional[int] = Field(None, gt=0)


class BOMItemResponse(BaseModel):
    bom_id: int
    material_name: str
    material_type: str
    quantity_required: float
    unit: str
    estimated_cost: Optional[float]
    
    class Config:
        from_attributes = True


class SubOrderResponse(BaseModel):
    sub_order_id: int
    task_type: str
    task_description: Optional[str]
    agreed_cost: Optional[float]
    status: str
    sequence_order: int
    vendor_name: Optional[str] = None
    
    class Config:
        from_attributes = True


class OrderResponse(BaseModel):
    order_id: int
    buyer_id: int
    design_prompt: Optional[str]
    generated_image_url: Optional[str]
    fabric_type: str
    quantity_meters: int
    thread_count: Optional[int]
    gsm: Optional[int]
    status: str
    total_cost: Optional[float]
    optimization_score: Optional[float]
    created_at: datetime
    estimated_delivery: Optional[datetime]
    
    class Config:
        from_attributes = True


class OrderDetailResponse(OrderResponse):
    bill_of_materials: List[BOMItemResponse] = []
    sub_orders: List[SubOrderResponse] = []
