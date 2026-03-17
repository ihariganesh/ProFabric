from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime
from app.models.product import ProductType

class ProductBase(BaseModel):
    type: ProductType
    name: str = Field(..., min_length=2, max_length=255)
    description: Optional[str] = None
    price_per_unit: float = Field(..., gt=0)
    unit: str = Field(..., min_length=1, max_length=50)
    max_capacity: Optional[int] = None
    min_order_quantity: int = 1
    lead_time_days: int = Field(..., ge=0)
    specifications: Optional[Dict[str, Any]] = None
    is_available: bool = True

class ProductCreate(ProductBase):
    pass

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price_per_unit: Optional[float] = None
    max_capacity: Optional[int] = None
    min_order_quantity: Optional[int] = None
    lead_time_days: Optional[int] = None
    specifications: Optional[Dict[str, Any]] = None
    is_available: Optional[bool] = None

class ProductResponse(ProductBase):
    item_id: int
    vendor_id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
