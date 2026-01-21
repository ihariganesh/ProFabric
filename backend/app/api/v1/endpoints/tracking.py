from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from typing import Dict, List

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


@router.get("/order/{order_id}")
async def get_order_tracking(order_id: int):
    """Get current tracking status of an order"""
    return {"message": "Tracking endpoint - to be implemented"}
