from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Dict, List, Optional
from datetime import datetime
import uuid

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.shipment import Shipment, ShipmentStatus
from app.models.order import SubOrder

router = APIRouter()


# WebSocket connection manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, List[WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, order_id: int):
        await websocket.accept()
        if order_id not in self.active_connections:
            self.active_connections[order_id] = []
        self.active_connections[order_id].append(websocket)
    
    def disconnect(self, websocket: WebSocket, order_id: int):
        if order_id in self.active_connections:
            self.active_connections[order_id].remove(websocket)
    
    async def send_update(self, order_id: int, message: dict):
        if order_id in self.active_connections:
            for connection in self.active_connections[order_id]:
                await connection.send_json(message)


manager = ConnectionManager()


@router.websocket("/ws/{order_id}")
async def websocket_tracking(websocket: WebSocket, order_id: int):
    """WebSocket endpoint for real-time order tracking"""
    await manager.connect(websocket, order_id)
    try:
        while True:
            # Keep connection alive
            data = await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket, order_id)


@router.get("/shipments")
async def get_shipments(
    status: Optional[str] = None,
    limit: int = Query(default=50, le=100),
    offset: int = 0,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all shipments for current logistics provider"""
    query = db.query(Shipment)
    
    # Filter by logistics provider if not admin
    if current_user.role != "Admin":
        query = query.filter(Shipment.logistics_provider_id == current_user.user_id)
    
    if status:
        try:
            status_enum = ShipmentStatus(status)
            query = query.filter(Shipment.current_status == status_enum)
        except ValueError:
            pass
    
    shipments = query.order_by(Shipment.created_at.desc()).offset(offset).limit(limit).all()
    
    return {
        "shipments": [
            {
                "shipment_id": s.shipment_id,
                "tracking_number": s.tracking_number,
                "sub_order_id": s.related_sub_order_id,
                "pickup_location": s.pickup_location,
                "pickup_coordinates": s.pickup_coordinates,
                "drop_location": s.drop_location,
                "drop_coordinates": s.drop_coordinates,
                "current_status": s.current_status.value if s.current_status else None,
                "vehicle_info": s.vehicle_info,
                "estimated_pickup": s.estimated_pickup.isoformat() if s.estimated_pickup else None,
                "actual_pickup": s.actual_pickup.isoformat() if s.actual_pickup else None,
                "estimated_delivery": s.estimated_delivery.isoformat() if s.estimated_delivery else None,
                "actual_delivery": s.actual_delivery.isoformat() if s.actual_delivery else None,
                "gps_checkpoints": s.gps_checkpoints or [],
                "created_at": s.created_at.isoformat() if s.created_at else None,
            }
            for s in shipments
        ],
        "total": query.count()
    }


@router.get("/shipments/{shipment_id}")
async def get_shipment(
    shipment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get shipment details by ID"""
    shipment = db.query(Shipment).filter(Shipment.shipment_id == shipment_id).first()
    
    if not shipment:
        raise HTTPException(status_code=404, detail="Shipment not found")
    
    return {
        "shipment_id": shipment.shipment_id,
        "tracking_number": shipment.tracking_number,
        "sub_order_id": shipment.related_sub_order_id,
        "logistics_provider_id": shipment.logistics_provider_id,
        "pickup_location": shipment.pickup_location,
        "pickup_coordinates": shipment.pickup_coordinates,
        "drop_location": shipment.drop_location,
        "drop_coordinates": shipment.drop_coordinates,
        "current_status": shipment.current_status.value if shipment.current_status else None,
        "vehicle_info": shipment.vehicle_info,
        "estimated_pickup": shipment.estimated_pickup.isoformat() if shipment.estimated_pickup else None,
        "actual_pickup": shipment.actual_pickup.isoformat() if shipment.actual_pickup else None,
        "estimated_delivery": shipment.estimated_delivery.isoformat() if shipment.estimated_delivery else None,
        "actual_delivery": shipment.actual_delivery.isoformat() if shipment.actual_delivery else None,
        "gps_checkpoints": shipment.gps_checkpoints or [],
        "delivery_proof_url": shipment.delivery_proof_url,
        "created_at": shipment.created_at.isoformat() if shipment.created_at else None,
        "updated_at": shipment.updated_at.isoformat() if shipment.updated_at else None,
    }


@router.post("/shipments")
async def create_shipment(
    shipment_data: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new shipment"""
    # Generate tracking number
    tracking_number = f"FF-{datetime.now().strftime('%Y%m%d')}-{str(uuid.uuid4())[:8].upper()}"
    
    shipment = Shipment(
        related_sub_order_id=shipment_data.get("sub_order_id"),
        logistics_provider_id=current_user.user_id,
        tracking_number=tracking_number,
        pickup_location=shipment_data.get("pickup_location", ""),
        pickup_coordinates=shipment_data.get("pickup_coordinates"),
        drop_location=shipment_data.get("drop_location", ""),
        drop_coordinates=shipment_data.get("drop_coordinates"),
        current_status=ShipmentStatus.PENDING_PICKUP,
        vehicle_info=shipment_data.get("vehicle_info"),
        estimated_pickup=datetime.fromisoformat(shipment_data["estimated_pickup"]) if shipment_data.get("estimated_pickup") else None,
        estimated_delivery=datetime.fromisoformat(shipment_data["estimated_delivery"]) if shipment_data.get("estimated_delivery") else None,
        gps_checkpoints=[],
    )
    
    db.add(shipment)
    db.commit()
    db.refresh(shipment)
    
    return {
        "message": "Shipment created successfully",
        "shipment_id": shipment.shipment_id,
        "tracking_number": shipment.tracking_number
    }


@router.put("/shipments/{shipment_id}/status")
async def update_shipment_status(
    shipment_id: int,
    status_data: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update shipment status"""
    shipment = db.query(Shipment).filter(Shipment.shipment_id == shipment_id).first()
    
    if not shipment:
        raise HTTPException(status_code=404, detail="Shipment not found")
    
    # Verify ownership for non-admin
    if current_user.role != "Admin" and shipment.logistics_provider_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="Not authorized to update this shipment")
    
    new_status = status_data.get("status")
    try:
        shipment.current_status = ShipmentStatus(new_status)
    except ValueError:
        raise HTTPException(status_code=400, detail=f"Invalid status: {new_status}")
    
    # Handle status-specific updates
    if new_status == ShipmentStatus.PICKED_UP.value:
        shipment.actual_pickup = datetime.utcnow()
    elif new_status == ShipmentStatus.DELIVERED.value:
        shipment.actual_delivery = datetime.utcnow()
        if status_data.get("delivery_proof_url"):
            shipment.delivery_proof_url = status_data["delivery_proof_url"]
    
    # Add GPS checkpoint if provided
    if status_data.get("checkpoint"):
        checkpoints = shipment.gps_checkpoints or []
        checkpoints.append({
            **status_data["checkpoint"],
            "timestamp": datetime.utcnow().isoformat(),
            "status": new_status
        })
        shipment.gps_checkpoints = checkpoints
    
    db.commit()
    
    # Notify via WebSocket
    if shipment.related_sub_order_id:
        await manager.send_update(shipment.related_sub_order_id, {
            "type": "shipment_update",
            "shipment_id": shipment_id,
            "status": new_status,
            "timestamp": datetime.utcnow().isoformat()
        })
    
    return {"message": "Status updated successfully", "status": new_status}


@router.post("/shipments/{shipment_id}/checkpoint")
async def add_checkpoint(
    shipment_id: int,
    checkpoint_data: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Add GPS checkpoint to shipment"""
    shipment = db.query(Shipment).filter(Shipment.shipment_id == shipment_id).first()
    
    if not shipment:
        raise HTTPException(status_code=404, detail="Shipment not found")
    
    checkpoints = shipment.gps_checkpoints or []
    checkpoints.append({
        "lat": checkpoint_data.get("lat"),
        "lng": checkpoint_data.get("lng"),
        "location_name": checkpoint_data.get("location_name", ""),
        "timestamp": datetime.utcnow().isoformat(),
        "notes": checkpoint_data.get("notes", "")
    })
    shipment.gps_checkpoints = checkpoints
    
    db.commit()
    
    # Notify via WebSocket
    if shipment.related_sub_order_id:
        await manager.send_update(shipment.related_sub_order_id, {
            "type": "checkpoint_added",
            "shipment_id": shipment_id,
            "checkpoint": checkpoints[-1]
        })
    
    return {"message": "Checkpoint added successfully"}


@router.get("/order/{order_id}")
async def get_order_tracking(
    order_id: int,
    db: Session = Depends(get_db)
):
    """Get all shipments for an order"""
    # Get sub_orders for this order
    sub_orders = db.query(SubOrder).filter(SubOrder.main_order_id == order_id).all()
    sub_order_ids = [so.sub_order_id for so in sub_orders]
    
    shipments = db.query(Shipment).filter(
        Shipment.related_sub_order_id.in_(sub_order_ids)
    ).all()
    
    return {
        "order_id": order_id,
        "shipments": [
            {
                "shipment_id": s.shipment_id,
                "tracking_number": s.tracking_number,
                "sub_order_id": s.related_sub_order_id,
                "pickup_location": s.pickup_location,
                "drop_location": s.drop_location,
                "current_status": s.current_status.value if s.current_status else None,
                "estimated_delivery": s.estimated_delivery.isoformat() if s.estimated_delivery else None,
                "gps_checkpoints": s.gps_checkpoints or [],
            }
            for s in shipments
        ]
    }


@router.get("/route/optimize")
async def get_optimized_route(
    origin_lat: float,
    origin_lng: float,
    dest_lat: float,
    dest_lng: float,
    current_user: User = Depends(get_current_user)
):
    """Get optimized route between two points (placeholder for real routing API)"""
    # In production, this would call Google Maps or HERE API
    # For now, return mock data
    return {
        "distance_km": 150.5,
        "estimated_duration_hours": 3.5,
        "route_polyline": "mock_polyline_data",
        "waypoints": [
            {"lat": origin_lat, "lng": origin_lng, "name": "Origin"},
            {"lat": (origin_lat + dest_lat) / 2, "lng": (origin_lng + dest_lng) / 2, "name": "Midpoint"},
            {"lat": dest_lat, "lng": dest_lng, "name": "Destination"}
        ],
        "fuel_estimate_liters": 15.5,
        "traffic_conditions": "moderate"
    }
