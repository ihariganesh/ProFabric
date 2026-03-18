from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import logging
from app.core.websockets.connection_manager import manager

router = APIRouter()
logger = logging.getLogger(__name__)

@router.websocket("/ws/orders/{order_id}")
async def order_tracking_ws(websocket: WebSocket, order_id: str):
    """
    WebSocket endpoint for real-time order tracking.
    Clients connect to listen to updates for a specific order.
    """
    topic = f"order_{order_id}"
    await manager.connect(websocket, topic=topic)
    try:
        while True:
            # Keep connection alive and listen for client messages if needed
            data = await websocket.receive_text()
            logger.info(f"Received WS message from client on {topic}: {data}")
    except WebSocketDisconnect:
        manager.disconnect(websocket, topic=topic)
        logger.info(f"Client disconnected from track order: {order_id}")

@router.websocket("/ws/edgeguard/{partner_id}")
async def edgeguard_stream_ws(websocket: WebSocket, partner_id: str):
    """
    WebSocket endpoint specifically for streaming live CV data / warnings 
    to Textile Hub or Admin dashboard.
    """
    topic = f"edgeguard_{partner_id}"
    await manager.connect(websocket, topic=topic)
    try:
        while True:
            data = await websocket.receive_text()
            # Clients (Partner nodes) can push bounding boxes or error rates 
            # and we can broadcast them back out to listening admins
            await manager.broadcast_to_topic("admin_edgeguard", {"from": partner_id, "data": data})
    except WebSocketDisconnect:
        manager.disconnect(websocket, topic=topic)
