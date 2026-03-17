import sys
import os
from sqlalchemy.orm import Session

# Add the current directory to sys.path
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(current_dir)

from app.core.database import SessionLocal
from app.services.optimization_service import OptimizationEngine
from app.models.user import User

def test_optimization():
    db = SessionLocal()
    
    # Get the buyer we created
    buyer = db.query(User).filter(User.email == "buyer@test.com").first()
    if not buyer:
        print("Error: Seeded buyer not found. Run seed_ecoflow_test.py first.")
        return

    material_type = "Thread"
    quantity = 100.0
    
    print(f"\n--- TEST 1: EcoFlow DISABLED ---")
    optimizer_normal = OptimizationEngine(db, use_sustainability=False)
    vendors_normal = optimizer_normal.find_best_material_vendors(
        material_type=material_type,
        quantity_required=quantity,
        buyer_location=buyer.location_data
    )
    
    for i, v in enumerate(vendors_normal):
        print(f"{i+1}. {v['vendor_name']} | Score: {v['score']} | Dist: {v['distance_km']}km | Price: ${v['price_per_unit']} | Material: {v['product_name']}")

    print(f"\n--- TEST 2: EcoFlow ENABLED ---")
    optimizer_eco = OptimizationEngine(db, use_sustainability=True)
    vendors_eco = optimizer_eco.find_best_material_vendors(
        material_type=material_type,
        quantity_required=quantity,
        buyer_location=buyer.location_data
    )
    
    for i, v in enumerate(vendors_eco):
        print(f"{i+1}. {v['vendor_name']} | Score: {v['score']} | Dist: {v['distance_km']}km | Price: ${v['price_per_unit']} | Sust. Score: {v['sustainability_score']} | Material: {v['product_name']}")

    # Check if rankings changed
    if vendors_normal[0]['vendor_id'] != vendors_eco[0]['vendor_id']:
        print("\n✅ SUCCESS: EcoFlow shifted the priority!")
        print(f"Top vendor changed from '{vendors_normal[0]['vendor_name']}' to '{vendors_eco[0]['vendor_name']}'")
    else:
        print("\nℹ️ INFO: Top vendor remained the same (Sustainability might not have outweighed cost/distance yet).")

if __name__ == "__main__":
    test_optimization()
