from typing import Dict, List, Any
from fastapi import WebSocket
import json
import logging

logger = logging.getLogger(__name__)

class ConnectionManager:
    """
    Manages WebSocket connections for real-time updates (Order timelines, 
    EdgeGuard live views, and RiskRadar alerts).
    """
    def __init__(self):
        # Maps order_id or topic -> List of connected WebSocket clients
        self.active_connections: Dict[str, List[WebSocket]] = {}
        # Maps user_id -> List of WebSockets for personal notifications
        self.user_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, topic: str = "global"):
        await websocket.accept()
        if topic not in self.active_connections:
            self.active_connections[topic] = []
        self.active_connections[topic].append(websocket)
        logger.info(f"Client connected to topic: {topic}")

    def disconnect(self, websocket: WebSocket, topic: str = "global"):
        if topic in self.active_connections and websocket in self.active_connections[topic]:
            self.active_connections[topic].remove(websocket)
            logger.info(f"Client disconnected from topic: {topic}")

    async def broadcast_to_topic(self, topic: str, message: dict):
        """
        Sends JSON message to all clients connected to a given topic (e.g. order_123)
        """
        if topic in self.active_connections:
            dead_connections = []
            payload = json.dumps(message)
            for connection in self.active_connections[topic]:
                try:
                    await connection.send_text(payload)
                except Exception as e:
                    logger.error(f"Failed to send WS message: {e}")
                    dead_connections.append(connection)
            
            # Clean up dead connections
            for dead in dead_connections:
                self.active_connections[topic].remove(dead)

manager = ConnectionManager()
