class EcoFlowOptimizer:
    """
    EcoFlow – Sustainability Optimizer
    Calculates carbon footprint based on logistics distance, fabric type, and printing method.
    Provides supplier scoring incorporating sustainability metrics.
    """
    
    @staticmethod
    def calculate_carbon_footprint(distance_km: float, fabric_type: str, printing_method: str) -> float:
        # Stub logic: carbon footprint in kg CO2
        base_emissions = distance_km * 0.05
        fabric_multipliers = {
            "cotton": 1.2,
            "polyester": 2.5,
            "organic_cotton": 0.8
        }
        printing_multipliers = {
            "digital": 1.0,
            "screen": 1.5,
            "dye_sublimation": 1.2
        }
        f_mult = fabric_multipliers.get(fabric_type.lower(), 1.0)
        p_mult = printing_multipliers.get(printing_method.lower(), 1.0)
        
        return base_emissions * f_mult * p_mult

    @staticmethod
    def score_supplier(cost: float, time_days: int, reliability: float, footprint: float, is_eco_mode: bool) -> float:
        """
        Integrates sustainability into supplier scoring.
        If eco_mode is True, sustainability index significantly impacts the final score.
        """
        # Normalize inverses (lower is better for cost/time/footprint)
        base_score = (1000 / (cost + 1)) + (100 / (time_days + 1)) + (reliability * 10)
        
        if is_eco_mode:
            eco_score = 1000 / (footprint + 1)
            return base_score * 0.4 + eco_score * 0.6
        return base_score * 0.8 + (1000 / (footprint + 1)) * 0.2
