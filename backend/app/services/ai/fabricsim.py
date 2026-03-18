import random

class FabricSim:
    """
    FabricSim – Digital Twin Simulator
    Simulates the full workflow using historical datasets prior to order confirmation.
    Returns bottleneck predictions, delay probability, and timeline optimizations.
    """

    @staticmethod
    def simulate_order_run(order_criteria: dict, selected_suppliers: list) -> dict:
        """
        Runs the digital twin simulation against historical performance data of the selected partner supply chain.
        """
        # Feature extraction (stub)
        total_volume = order_criteria.get("volume", 100)
        complexity = order_criteria.get("complexity", "medium")
        
        # Simulate predictions based on historical dataset proxies
        base_delay_chance = 0.05
        if complexity == "high":
            base_delay_chance += 0.15
            
        bottlenecks = []
        if total_volume > 5000:
            bottlenecks.append("Stitching capacity at bounds - 12% delay expected in phase 3")
            
        delay_probability = min(1.0, base_delay_chance + (random.random() * 0.1))
        
        return {
            "delay_probability": round(delay_probability, 3),
            "predicted_timeline_days": 45 if delay_probability < 0.2 else 52,
            "bottlenecks": bottlenecks,
            "optimization_suggestions": [
                "Split order across two stitching units",
                "Approve digital sample instead of physical to save 4 days"
            ]
        }
