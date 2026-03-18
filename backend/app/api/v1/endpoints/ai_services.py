from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from pydantic import BaseModel
from typing import List

from app.services.ai.ecoflow import EcoFlowOptimizer
from app.services.ai.fabricsim import FabricSim
from app.services.ai.edgeguard import EdgeGuardQC
# from app.services.ai.riskradar import RiskRadar  # Accessed typically via background jobs

router = APIRouter()

class OrderCriteria(BaseModel):
    volume: int
    complexity: str
    fabric_type: str
    printing_method: str
    distance_km: float
    eco_mode: bool = False

class SupplierScore(BaseModel):
    supplier_id: str
    base_cost: float
    time_days: int
    reliability: float

class EcoFlowRequest(BaseModel):
    order_criteria: OrderCriteria
    supplier: SupplierScore

@router.post("/ecoflow/score")
async def get_ecoflow_score(request: EcoFlowRequest):
    """
    Evaluates a specific supplier against order criteria and returns an optimal sustainability score.
    """
    footprint = EcoFlowOptimizer.calculate_carbon_footprint(
        request.order_criteria.distance_km,
        request.order_criteria.fabric_type,
        request.order_criteria.printing_method
    )
    score = EcoFlowOptimizer.score_supplier(
        request.supplier.base_cost,
        request.supplier.time_days,
        request.supplier.reliability,
        footprint,
        request.order_criteria.eco_mode
    )
    return {"carbon_footprint": footprint, "final_score": score}

@router.post("/fabricsim/simulate")
async def run_fabricsim(criteria: dict):
    """
    Executes a Digital Twin timeline simulation.
    """
    result = FabricSim.simulate_order_run(criteria, [])
    return result

@router.post("/edgeguard/detect")
async def run_edgeguard_qc(file: UploadFile = File(...)):
    """
    Ingests an image from the factory partner and returns YOLO defect bounding boxes.
    """
    content = await file.read()
    result = EdgeGuardQC.analyze_frame(content)
    return result
