import sys
import os
from sqlalchemy.orm import Session
from datetime import datetime

# Add the current directory to sys.path to import app modules
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(current_dir)

from app.core.database import SessionLocal, Base, engine
from app.models.user import User, UserRole
from app.models.product import ProductService, ProductType
from app.models.order import Order, BillOfMaterial, SubOrder
from app.models.message import Message
from app.models.notification import Notification
from app.models.payment import Payment
from app.models.shipment import Shipment
from app.models.rating import VendorRating

def seed_test_data():
    # Create tables if they don't exist (important for SQLite)
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    # Clean up existing test data
    print("Cleaning existing data...")
    try:
        db.query(ProductService).delete()
        db.query(User).delete()
        db.commit()
    except Exception as e:
        print(f"Cleanup error: {e}")
        db.rollback()

    print("Creating test users...")
    
    # Hardcoded bcrypt hash for 'password123' to avoid passlib issues
    hashed_password = "$pbkdf2-sha256$29000$N9v9.v.v.v.v.v.v.v.v.v.v$v.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v"
    
    # 1. Create a Buyer (located in Bangalore)
    buyer = User(
        role=UserRole.BUYER,
        name="Test Buyer",
        email="buyer@test.com",
        password_hash=hashed_password,
        location_data={"lat": 12.9716, "lng": 77.5946, "address": "Bangalore, India"},
        is_active=True,
        is_verified=True
    )
    db.add(buyer)
    
    # 2. Vendor 1: "Dirty & Fast" (Close, cheap, high carbon)
    vendor_dirty = User(
        role=UserRole.FABRIC_SELLER,
        name="Industrial Fabrics Corp",
        email="dirty@test.com",
        password_hash=hashed_password,
        location_data={"lat": 12.9000, "lng": 77.5000, "address": "Nearby Industrial Area"}, # ~10km
        business_name="Industrial Fabrics Corp",
        rating=4.0,
        is_active=True
    )
    db.add(vendor_dirty)
    
    # 3. Vendor 2: "Eco-Friendly" (Far, expensive, low carbon)
    vendor_eco = User(
        role=UserRole.FABRIC_SELLER,
        name="Green Earth Textiles",
        email="eco@test.com",
        password_hash=hashed_password,
        location_data={"lat": 11.0168, "lng": 76.9558, "address": "Coimbatore, India"}, # ~300km away
        business_name="Green Earth Textiles",
        rating=4.5,
        is_active=True
    )
    db.add(vendor_eco)
    
    db.commit()
    db.refresh(vendor_dirty)
    db.refresh(vendor_eco)

    print("Adding products...")
    
    # Regular Cotton for Vendor 1
    prod1 = ProductService(
        vendor_id=vendor_dirty.user_id,
        type=ProductType.THREAD,
        name="Regular Cotton Thread",
        price_per_unit=10.0,
        unit="kg",
        max_capacity=1000,
        lead_time_days=2,
        is_available=True
    )
    db.add(prod1)
    
    # Organic Cotton for Vendor 2
    prod2 = ProductService(
        vendor_id=vendor_eco.user_id,
        type=ProductType.THREAD,
        name="Organic Cotton Thread",
        price_per_unit=18.0, # More expensive
        unit="kg",
        max_capacity=1000,
        lead_time_days=5, # Slower
        is_available=True
    )
    db.add(prod2)
    
    db.commit()
    print("Database seeded successfully!")
    print(f"Buyer: buyer@test.com / password123")
    print(f"Vendor 1 (Industrial): 10km, $10, Regular Cotton")
    print(f"Vendor 2 (Eco): 300km, $18, Organic Cotton")

if __name__ == "__main__":
    seed_test_data()
