from typing import List, Dict, Optional
from sqlalchemy.orm import Session
from sqlalchemy import and_
import math
from geopy.distance import geodesic

from app.models.user import User
from app.models.product import ProductService, ProductType
from app.models.order import Order, BillOfMaterial, SubOrder, TaskType, SubOrderStatus
from app.core.config import settings


class OptimizationEngine:
    """Core optimization engine for supply chain routing with EcoFlow and RiskRadar integration"""
    
    # Carbon footprint factors (estimated kg CO2 per kg material or per 100km transport)
    CARBON_FACTORS = {
        "material": {
            "cotton": 20.0,
            "polyester": 35.0,
            "silk": 45.0,
            "organic_cotton": 2.0,
            "recycled_polyester": 5.0
        },
        "transport": 2.0, # Increased transport impact
        "process": {
            "weaving": 5.0,
            "dyeing": 10.0,
            "finishing": 4.0
        }
    }
    
    def __init__(self, db: Session, use_sustainability: bool = False):
        self.db = db
        self.use_sustainability = use_sustainability
        
        self.cost_weight = settings.OPTIMIZATION_COST_WEIGHT
        self.speed_weight = settings.OPTIMIZATION_SPEED_WEIGHT
        self.quality_weight = settings.OPTIMIZATION_QUALITY_WEIGHT
        self.sustainability_weight = settings.OPTIMIZATION_SUSTAINABILITY_WEIGHT
        
        # Adjust weights if sustainability is enabled to make it impactful
        if use_sustainability:
            # Scale down others to keep total weight around 1.0-1.3 or re-normalize
            # For testing simplicity, we'll just ensure sustainability has its own weight
            pass
        else:
            self.sustainability_weight = 0.0
    
    def calculate_sustainability_score(self, material_type: str, distance: float, quantity: float) -> float:
        """Calculate sustainability score based on carbon footprint (0-1, higher is better)"""
        material_factor = self.CARBON_FACTORS["material"].get(material_type.lower(), 7.0)
        transport_factor = self.CARBON_FACTORS["transport"]
        
        # Total estimated carbon footprint
        carbon_footprint = (material_factor * quantity) + (transport_factor * (distance / 100) * quantity)
        
        # Normalize to 0-1 (inverse of footprint, with some reasonable max threshold for scaling)
        # Assuming a "bad" footprint is 100kg CO2 per unit of order, 0 is perfect
        max_carbon_threshold = 50.0 * quantity 
        score = 1 - min(carbon_footprint / max_carbon_threshold, 1.0)
        return score

    def apply_risk_radar(self, vendor_id: int, base_rating: float) -> float:
        """Adjust reliability score based on real-time risk data (RiskRadar)"""
        # In a real implementation, this would query a 'disruptions' table or cache
        # affected by the RiskRadar NLP engine
        # For now, we simulate a check
        return base_rating # Default to base rating if no active risk
    
    def calculate_distance(self, loc1: dict, loc2: dict) -> float:
        """Calculate distance between two locations in kilometers"""
        if not loc1 or not loc2:
            return 0.0
        
        try:
            point1 = (loc1.get("lat"), loc1.get("lng"))
            point2 = (loc2.get("lat"), loc2.get("lng"))
            return geodesic(point1, point2).kilometers
        except:
            return 0.0
    
    def normalize_score(self, value: float, min_val: float, max_val: float) -> float:
        """Normalize a value to 0-1 range"""
        if max_val == min_val:
            return 0.5
        return (value - min_val) / (max_val - min_val)
    
    def find_best_material_vendors(
        self,
        material_type: str,
        quantity_required: float,
        buyer_location: dict
    ) -> List[Dict]:
        """Find best vendors for a specific material"""
        
        # Query available vendors
        vendors = self.db.query(ProductService, User).join(
            User, ProductService.vendor_id == User.user_id
        ).filter(
            and_(
                ProductService.type == material_type,
                ProductService.is_available == True,
                User.is_active == True,
                ProductService.max_capacity >= quantity_required
            )
        ).all()
        
        if not vendors:
            return []
        
        # Calculate scores for each vendor
        scored_vendors = []
        
        # Get min/max values for normalization
        prices = [v[0].price_per_unit for v in vendors]
        lead_times = [v[0].lead_time_days for v in vendors]
        ratings = [v[1].rating for v in vendors]
        
        min_price, max_price = min(prices), max(prices)
        min_lead, max_lead = min(lead_times), max(lead_times)
        min_rating, max_rating = min(ratings) if ratings else 0, max(ratings) if ratings else 5
        
        for product, user in vendors:
            # Calculate distance
            distance = self.calculate_distance(buyer_location, user.location_data)
            
            # Normalize individual factors (lower is better for cost and speed)
            cost_score = 1 - self.normalize_score(product.price_per_unit, min_price, max_price)
            speed_score = 1 - self.normalize_score(product.lead_time_days + (distance / 100), min_lead, max_lead)
            
            # Apply RiskRadar to quality/reliability score
            adjusted_rating = self.apply_risk_radar(user.user_id, user.rating)
            quality_score = self.normalize_score(adjusted_rating, 0, 5)
            
            # Calculate Sustainability Score if enabled
            sustainability_score = 0.0
            if self.use_sustainability:
                # Use product name or specific sub-type for more accurate carbon factor
                search_term = product.name.lower()
                sustainability_score = self.calculate_sustainability_score(
                    search_term, distance, quantity_required
                )
            
            # Calculate weighted total score
            total_score = (
                cost_score * self.cost_weight +
                speed_score * self.speed_weight +
                quality_score * self.quality_weight +
                sustainability_score * self.sustainability_weight
            )
            
            scored_vendors.append({
                "vendor_id": user.user_id,
                "vendor_name": user.name,
                "business_name": user.business_name,
                "product_id": product.item_id,
                "product_name": product.name,
                "price_per_unit": product.price_per_unit,
                "unit": product.unit,
                "lead_time_days": product.lead_time_days,
                "rating": user.rating,
                "distance_km": round(distance, 2),
                "score": round(total_score, 4),
                "cost_score": round(cost_score, 4),
                "speed_score": round(speed_score, 4),
                "quality_score": round(quality_score, 4),
                "sustainability_score": round(sustainability_score, 4),
                "location": user.location_data
            })
        
        # Sort by total score (highest first)
        scored_vendors.sort(key=lambda x: x["score"], reverse=True)
        
        return scored_vendors
    
    def find_best_manufacturers(
        self,
        service_type: str,
        buyer_location: dict,
        material_vendor_location: dict
    ) -> List[Dict]:
        """Find best manufacturing units"""
        
        # Map service types
        service_type_map = {
            "weaving": ProductType.WEAVING_SERVICE,
            "knitting": ProductType.KNITTING_SERVICE,
            "dyeing": ProductType.DYEING_SERVICE,
            "finishing": ProductType.FINISHING_SERVICE
        }
        
        product_type = service_type_map.get(service_type.lower(), ProductType.WEAVING_SERVICE)
        
        # Query available manufacturers
        manufacturers = self.db.query(ProductService, User).join(
            User, ProductService.vendor_id == User.user_id
        ).filter(
            and_(
                ProductService.type == product_type,
                ProductService.is_available == True,
                User.is_active == True
            )
        ).all()
        
        if not manufacturers:
            return []
        
        scored_manufacturers = []
        
        for product, user in manufacturers:
            # Distance from material vendor (pickup) and to buyer (delivery)
            distance_from_vendor = self.calculate_distance(
                material_vendor_location,
                user.location_data
            )
            distance_to_buyer = self.calculate_distance(
                user.location_data,
                buyer_location
            )
            total_distance = distance_from_vendor + distance_to_buyer
            
            # Calculate scores
            cost_factor = product.price_per_unit
            speed_factor = product.lead_time_days + (total_distance / 100)
            quality_factor = user.rating
            
            # Simple scoring
            score = (
                (1 / (cost_factor + 1)) * self.cost_weight +
                (1 / (speed_factor + 1)) * self.speed_weight +
                (quality_factor / 5) * self.quality_weight
            )
            
            scored_manufacturers.append({
                "vendor_id": user.user_id,
                "vendor_name": user.name,
                "business_name": user.business_name,
                "product_id": product.item_id,
                "service_name": product.name,
                "price_per_unit": product.price_per_unit,
                "lead_time_days": product.lead_time_days,
                "rating": user.rating,
                "distance_from_vendor_km": round(distance_from_vendor, 2),
                "distance_to_buyer_km": round(distance_to_buyer, 2),
                "total_distance_km": round(total_distance, 2),
                "score": round(score, 4),
                "location": user.location_data
            })
        
        scored_manufacturers.sort(key=lambda x: x["score"], reverse=True)
        
        return scored_manufacturers
    
    def find_best_logistics(
        self,
        pickup_location: dict,
        delivery_location: dict
    ) -> List[Dict]:
        """Find best logistics providers"""
        
        # Query available logistics providers
        logistics = self.db.query(ProductService, User).join(
            User, ProductService.vendor_id == User.user_id
        ).filter(
            and_(
                ProductService.type == ProductType.TRANSPORT_SERVICE,
                ProductService.is_available == True,
                User.is_active == True
            )
        ).all()
        
        if not logistics:
            return []
        
        scored_logistics = []
        
        distance = self.calculate_distance(pickup_location, delivery_location)
        
        for product, user in logistics:
            # Calculate cost based on distance
            estimated_cost = product.price_per_unit * (distance / 100)  # per 100km
            
            score = (
                (1 / (estimated_cost + 1)) * self.cost_weight +
                (1 / (product.lead_time_days + 1)) * self.speed_weight +
                (user.rating / 5) * self.quality_weight
            )
            
            scored_logistics.append({
                "vendor_id": user.user_id,
                "vendor_name": user.name,
                "business_name": user.business_name,
                "product_id": product.item_id,
                "service_name": product.name,
                "base_price_per_100km": product.price_per_unit,
                "estimated_cost": round(estimated_cost, 2),
                "estimated_days": product.lead_time_days,
                "rating": user.rating,
                "distance_km": round(distance, 2),
                "score": round(score, 4),
                "location": user.location_data
            })
        
        scored_logistics.sort(key=lambda x: x["score"], reverse=True)
        
        return scored_logistics
    
    def create_optimized_supply_chain(self, order_id: int) -> Dict:
        """Create optimized supply chain route for an order"""
        
        # Get order and BOM
        order = self.db.query(Order).filter(Order.order_id == order_id).first()
        if not order:
            raise ValueError("Order not found")
        
        buyer = self.db.query(User).filter(User.user_id == order.buyer_id).first()
        bom_items = self.db.query(BillOfMaterial).filter(
            BillOfMaterial.order_id == order_id
        ).all()
        
        buyer_location = buyer.location_data
        
        supply_chain = {
            "order_id": order_id,
            "optimization_score": 0.0,
            "total_estimated_cost": 0.0,
            "total_estimated_days": 0,
            "sub_orders": []
        }
        
        sequence = 1
        previous_location = buyer_location
        
        # Step 1: Find material vendors
        for bom in bom_items:
            vendors = self.find_best_material_vendors(
                material_type=bom.material_type,
                quantity_required=bom.quantity_required,
                buyer_location=buyer_location
            )
            
            if vendors:
                best_vendor = vendors[0]
                
                # Create sub-order for material supply
                sub_order_data = {
                    "vendor": best_vendor,
                    "task_type": TaskType.SUPPLY_MATERIAL,
                    "sequence": sequence,
                    "estimated_cost": best_vendor["price_per_unit"] * bom.quantity_required,
                    "estimated_days": best_vendor["lead_time_days"]
                }
                
                supply_chain["sub_orders"].append(sub_order_data)
                supply_chain["total_estimated_cost"] += sub_order_data["estimated_cost"]
                supply_chain["total_estimated_days"] = max(
                    supply_chain["total_estimated_days"],
                    sub_order_data["estimated_days"]
                )
                
                previous_location = best_vendor["location"]
                sequence += 1
        
        # Step 2: Find manufacturer
        manufacturers = self.find_best_manufacturers(
            service_type="weaving",  # Based on fabric type
            buyer_location=buyer_location,
            material_vendor_location=previous_location
        )
        
        if manufacturers:
            best_manufacturer = manufacturers[0]
            
            sub_order_data = {
                "vendor": best_manufacturer,
                "task_type": TaskType.MANUFACTURE,
                "sequence": sequence,
                "estimated_cost": best_manufacturer["price_per_unit"] * order.quantity_meters,
                "estimated_days": best_manufacturer["lead_time_days"]
            }
            
            supply_chain["sub_orders"].append(sub_order_data)
            supply_chain["total_estimated_cost"] += sub_order_data["estimated_cost"]
            supply_chain["total_estimated_days"] += sub_order_data["estimated_days"]
            
            previous_location = best_manufacturer["location"]
            sequence += 1
        
        # Step 3: Find logistics for final delivery
        logistics = self.find_best_logistics(
            pickup_location=previous_location,
            delivery_location=buyer_location
        )
        
        if logistics:
            best_logistics = logistics[0]
            
            sub_order_data = {
                "vendor": best_logistics,
                "task_type": TaskType.TRANSPORT,
                "sequence": sequence,
                "estimated_cost": best_logistics["estimated_cost"],
                "estimated_days": best_logistics["estimated_days"]
            }
            
            supply_chain["sub_orders"].append(sub_order_data)
            supply_chain["total_estimated_cost"] += sub_order_data["estimated_cost"]
            supply_chain["total_estimated_days"] += sub_order_data["estimated_days"]
        
        # Calculate overall optimization score
        if supply_chain["sub_orders"]:
            avg_score = sum(so["vendor"]["score"] for so in supply_chain["sub_orders"]) / len(supply_chain["sub_orders"])
            supply_chain["optimization_score"] = round(avg_score, 4)
        
        return supply_chain

    def simulate_run(self, supply_chain: Dict) -> Dict:
        """FabricSim: Predict potential bottlenecks and energy consumption"""
        import random
        
        simulation_results = {
            "predicted_bottlenecks": [],
            "total_estimated_energy_kwh": 0.0,
            "delay_probability": 0.0,
            "confidence_score": 0.85
        }
        
        for sub_order in supply_chain["sub_orders"]:
            task_type = sub_order["task_type"]
            
            # Predict delay based on task type and random factors (simulating 'Monsoon' or 'Energy shortage')
            # In production, this would use the historical dataset
            risk_factor = random.random()
            
            if task_type == TaskType.DYEING and risk_factor > 0.7:
                simulation_results["predicted_bottlenecks"].append({
                    "stage": "Dyeing",
                    "issue": "High chance of delay during high-humidity season",
                    "probability": 0.9
                })
            
            # Estimate energy consumption
            if task_type == TaskType.MANUFACTURE:
                simulation_results["total_estimated_energy_kwh"] += random.uniform(500, 1500)
            elif task_type == TaskType.TRANSPORT:
                simulation_results["total_estimated_energy_kwh"] += random.uniform(50, 200)
                
        simulation_results["delay_probability"] = 0.1 + (len(simulation_results["predicted_bottlenecks"]) * 0.2)
        
        return simulation_results

    async def edge_guard_defect_detection(self, image_data: str) -> Dict:
        """EdgeGuard: Detect defects using computer vision (YOLO)"""
        # This calls the AI service which would handle the YOLO model
        from app.services.ai_service import AIDesignService
        
        # Simulated YOLO response
        defects = [
            {"type": "Hole", "confidence": 0.98, "location": {"x": 120, "y": 450}},
            {"type": "Stain", "confidence": 0.85, "location": {"x": 800, "y": 210}}
        ]
        
        return {
            "defect_map_url": "https://api.profabric.com/v1/qc/map/123.png",
            "defects_found": len(defects),
            "details": defects,
            "status": "Warning" if defects else "Pass"
        }
