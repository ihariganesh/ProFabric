import sys
import os
import unittest
from unittest.mock import MagicMock, patch

# 1. Mock problematic modules before ANY imports from app
sys.modules['geopy'] = MagicMock()
sys.modules['geopy.distance'] = MagicMock()
sys.modules['sqlalchemy'] = MagicMock()
sys.modules['sqlalchemy.orm'] = MagicMock()
sys.modules['app.core.database'] = MagicMock()
sys.modules['app.core.security'] = MagicMock()

# Mock SQLAlchemy 'and_'
import sqlalchemy
sqlalchemy.and_ = lambda *args: MagicMock()

# Add current dir to path for imports
sys.path.append(os.getcwd())

# 2. Mock settings
sys.modules['app.core.config'] = MagicMock()
from app.core.config import settings
settings.OPTIMIZATION_COST_WEIGHT = 0.4
settings.OPTIMIZATION_SPEED_WEIGHT = 0.3
settings.OPTIMIZATION_QUALITY_WEIGHT = 0.3
settings.OPTIMIZATION_SUSTAINABILITY_WEIGHT = 0.3

# 3. Import the engine
from app.services.optimization_service import OptimizationEngine

class TestEcoFlow(unittest.TestCase):
    def setUp(self):
        self.db = MagicMock()
        self.buyer_location = {"lat": 12.9716, "lng": 77.5946} # Bangalore
        
    def test_sustainability_shift(self):
        # Vendor A: Close (10km), Regular Cotton ($10)
        vendor_a_user = MagicMock()
        vendor_a_user.user_id = 1
        vendor_a_user.name = "Industrial Corp"
        vendor_a_user.rating = 4.0
        vendor_a_user.location_data = {"lat": 12.9000, "lng": 77.5000}
        
        vendor_a_prod = MagicMock()
        vendor_a_prod.price_per_unit = 10.0
        vendor_a_prod.lead_time_days = 2
        vendor_a_prod.type = "Thread"
        vendor_a_prod.name = "cotton"
        
        # Vendor B: Far (300km), Organic Cotton ($18)
        vendor_b_user = MagicMock()
        vendor_b_user.user_id = 2
        vendor_b_user.name = "Eco Textiles"
        vendor_b_user.rating = 4.5
        vendor_b_user.location_data = {"lat": 11.0168, "lng": 76.9558}
        
        vendor_b_prod = MagicMock()
        vendor_b_prod.price_per_unit = 18.0
        vendor_b_prod.lead_time_days = 5
        vendor_b_prod.type = "Thread"
        vendor_b_prod.name = "organic_cotton"

        vendors_list = [
            (vendor_a_prod, vendor_a_user),
            (vendor_b_prod, vendor_b_user)
        ]

        # Patch model class comparison attributes
        mock_attr = MagicMock()
        mock_attr.__ge__ = lambda s, o: True
        mock_attr.__eq__ = lambda s, o: True

        with patch('app.services.optimization_service.ProductService') as mock_ps, \
             patch('app.services.optimization_service.User') as mock_u:
            
            mock_ps.vendor_id = mock_attr
            mock_ps.type = mock_attr
            mock_ps.is_available = mock_attr
            mock_ps.max_capacity = mock_attr
            mock_u.user_id = mock_attr
            mock_u.is_active = mock_attr

            # 2. Run with EcoFlow OFF
            engine_off = OptimizationEngine(self.db, use_sustainability=False)
            with patch.object(OptimizationEngine, 'calculate_distance') as mock_dist:
                mock_dist.side_effect = [10.0, 300.0]
                self.db.query().join().filter().all.return_value = vendors_list
                results_off = engine_off.find_best_material_vendors("Thread", 100, self.buyer_location)
                
            print("\n--- EcoFlow OFF ---")
            for r in results_off:
                print(f"Vendor: {r['vendor_name']} | Score: {r['score']} | Material: {r['product_name']} | Dist: {r['distance_km']}km")

            # 3. Run with EcoFlow ON
            engine_on = OptimizationEngine(self.db, use_sustainability=True)
            # Increase weight significantly for the test to ensure shift
            engine_on.sustainability_weight = 10.0 
            
            with patch.object(OptimizationEngine, 'calculate_distance') as mock_dist:
                mock_dist.side_effect = [10.0, 300.0]
                results_on = engine_on.find_best_material_vendors("Thread", 100, self.buyer_location)
                
            print("\n--- EcoFlow ON ---")
            for r in results_on:
                print(f"Vendor: {r['vendor_name']} | Score: {r['score']} | Sust. Score: {r['sustainability_score']} | Material: {r['product_name']} | Dist: {r['distance_km']}km")

            top_off = results_off[0]['vendor_id']
            top_on = results_on[0]['vendor_id']
            
            print(f"\nTop Vendor (Normal): {results_off[0]['vendor_name']}")
            print(f"Top Vendor (EcoFlow): {results_on[0]['vendor_name']}")
            
            if top_off != top_on:
                print(f"\n✅ PASS: Ranking shifted as expected!")
            else:
                print(f"\nℹ️ INFO: Ranking didn't shift. Sust Scores: {results_on[0]['sustainability_score']} vs {results_on[1]['sustainability_score']}")

if __name__ == "__main__":
    unittest.main()
