from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app.core.database import get_db
from app.core.security import get_current_active_user
from app.models.user import User
from app.models.product import ProductService
from app.schemas.product import ProductResponse, ProductCreate, ProductUpdate

router = APIRouter()

@router.get("/", response_model=List[ProductResponse])
async def list_products(
    skip: int = 0,
    limit: int = Query(default=100, le=100),
    vendor_id: Optional[int] = None,
    product_type: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """List available products and services"""
    query = db.query(ProductService).filter(ProductService.is_available == True)
    if vendor_id:
        query = query.filter(ProductService.vendor_id == vendor_id)
    if product_type:
        query = query.filter(ProductService.type == product_type)
        
    products = query.offset(skip).limit(limit).all()
    return products

@router.get("/{item_id}", response_model=ProductResponse)
async def get_product(
    item_id: int,
    db: Session = Depends(get_db)
):
    """Get a specific product or service by ID"""
    product = db.query(ProductService).filter(ProductService.item_id == item_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@router.post("/", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_product(
    product_data: ProductCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Create a new product or service (vendors only)"""
    if current_user.role == "Buyer":
        raise HTTPException(status_code=403, detail="Buyers cannot create products")
        
    product = ProductService(
        vendor_id=current_user.user_id,
        **product_data.dict()
    )
    db.add(product)
    db.commit()
    db.refresh(product)
    return product

@router.put("/{item_id}", response_model=ProductResponse)
async def update_product(
    item_id: int,
    product_data: ProductUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update a product or service"""
    product = db.query(ProductService).filter(ProductService.item_id == item_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    if product.vendor_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="Not authorized to update this product")
        
    update_data = product_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(product, key, value)
        
    db.commit()
    db.refresh(product)
    return product

@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(
    item_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Delete (or mark unavailable) a product"""
    product = db.query(ProductService).filter(ProductService.item_id == item_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    if product.vendor_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this product")
        
    # Soft delete
    product.is_available = False
    db.commit()
    return None
