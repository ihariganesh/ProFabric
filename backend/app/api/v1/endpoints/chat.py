"""
WebSocket Chat Endpoints

Provides real-time messaging capabilities for the textile supply chain platform.
Uses FastAPI WebSocket support with room-based messaging for order-specific chats.
"""

from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query
from typing import Dict, List, Optional
from datetime import datetime
import json
import uuid

from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.message import Message


router = APIRouter(prefix="/chat", tags=["Chat"])


class ConnectionManager:
    """Manages WebSocket connections and message routing"""
    
    def __init__(self):
        # user_id -> WebSocket mapping
        self.active_connections: Dict[str, WebSocket] = {}
        # room_id -> set of user_ids
        self.rooms: Dict[str, set] = {}
        # user_id -> user info
        self.user_info: Dict[str, dict] = {}
    
    async def connect(self, websocket: WebSocket, user_id: str, user_name: str):
        """Accept a new WebSocket connection"""
        await websocket.accept()
        self.active_connections[user_id] = websocket
        self.user_info[user_id] = {
            "user_id": user_id,
            "user_name": user_name,
            "connected_at": datetime.utcnow().isoformat(),
        }
        print(f"User {user_id} ({user_name}) connected")
    
    def disconnect(self, user_id: str):
        """Remove a WebSocket connection"""
        if user_id in self.active_connections:
            del self.active_connections[user_id]
        if user_id in self.user_info:
            del self.user_info[user_id]
        
        # Remove user from all rooms
        for room_id in list(self.rooms.keys()):
            self.rooms[room_id].discard(user_id)
            if not self.rooms[room_id]:
                del self.rooms[room_id]
        
        print(f"User {user_id} disconnected")
    
    def join_room(self, user_id: str, room_id: str):
        """Add user to a chat room"""
        if room_id not in self.rooms:
            self.rooms[room_id] = set()
        self.rooms[room_id].add(user_id)
        print(f"User {user_id} joined room {room_id}")
    
    def leave_room(self, user_id: str, room_id: str):
        """Remove user from a chat room"""
        if room_id in self.rooms:
            self.rooms[room_id].discard(user_id)
            if not self.rooms[room_id]:
                del self.rooms[room_id]
        print(f"User {user_id} left room {room_id}")
    
    async def send_personal_message(self, message: dict, user_id: str):
        """Send a message to a specific user"""
        if user_id in self.active_connections:
            websocket = self.active_connections[user_id]
            try:
                await websocket.send_json(message)
            except Exception as e:
                print(f"Error sending to {user_id}: {e}")
    
    async def broadcast_to_room(self, message: dict, room_id: str, exclude_user: str = None):
        """Broadcast a message to all users in a room"""
        if room_id not in self.rooms:
            return
        
        for user_id in self.rooms[room_id]:
            if user_id != exclude_user and user_id in self.active_connections:
                try:
                    await self.active_connections[user_id].send_json(message)
                except Exception as e:
                    print(f"Error broadcasting to {user_id}: {e}")
    
    async def broadcast_to_all(self, message: dict, exclude_user: str = None):
        """Broadcast a message to all connected users"""
        for user_id, websocket in self.active_connections.items():
            if user_id != exclude_user:
                try:
                    await websocket.send_json(message)
                except Exception as e:
                    print(f"Error broadcasting to {user_id}: {e}")
    
    def get_online_users(self) -> List[str]:
        """Get list of online user IDs"""
        return list(self.active_connections.keys())
    
    def get_room_users(self, room_id: str) -> List[str]:
        """Get list of users in a room"""
        return list(self.rooms.get(room_id, set()))
    
    def is_user_online(self, user_id: str) -> bool:
        """Check if a user is online"""
        return user_id in self.active_connections


# Global connection manager
manager = ConnectionManager()


@router.websocket("/ws/{user_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    user_id: str,
    user_name: str = Query(default="User"),
):
    """
    WebSocket endpoint for real-time chat
    
    Messages are JSON objects with the following structure:
    {
        "event": "send_message" | "typing" | "join_room" | "leave_room" | "mark_read",
        "data": { ... event-specific data ... }
    }
    """
    await manager.connect(websocket, user_id, user_name)
    
    try:
        # Notify others that user is online
        await manager.broadcast_to_all({
            "event": "user_online",
            "data": {
                "userId": user_id,
                "userName": user_name,
                "timestamp": datetime.utcnow().isoformat(),
            }
        }, exclude_user=user_id)
        
        while True:
            # Receive message from client
            data = await websocket.receive_json()
            event = data.get("event", "")
            payload = data.get("data", {})
            
            # Handle different event types
            if event == "send_message":
                await handle_send_message(user_id, user_name, payload)
            
            elif event == "typing":
                await handle_typing(user_id, user_name, payload)
            
            elif event == "join_room":
                room_id = payload.get("roomId")
                if room_id:
                    manager.join_room(user_id, room_id)
                    await manager.broadcast_to_room({
                        "event": "user_joined",
                        "data": {
                            "userId": user_id,
                            "userName": user_name,
                            "roomId": room_id,
                        }
                    }, room_id, exclude_user=user_id)
            
            elif event == "leave_room":
                room_id = payload.get("roomId")
                if room_id:
                    manager.leave_room(user_id, room_id)
                    await manager.broadcast_to_room({
                        "event": "user_left",
                        "data": {
                            "userId": user_id,
                            "userName": user_name,
                            "roomId": room_id,
                        }
                    }, room_id)
            
            elif event == "mark_read":
                await handle_mark_read(user_id, payload)
            
            elif event == "get_online_status":
                target_user_id = payload.get("userId")
                is_online = manager.is_user_online(target_user_id)
                await manager.send_personal_message({
                    "event": "online_status",
                    "data": {
                        "userId": target_user_id,
                        "isOnline": is_online,
                    }
                }, user_id)
            
            elif event == "get_online_users":
                online_users = manager.get_online_users()
                await manager.send_personal_message({
                    "event": "online_users",
                    "data": {"users": online_users}
                }, user_id)
    
    except WebSocketDisconnect:
        manager.disconnect(user_id)
        
        # Notify others that user went offline
        await manager.broadcast_to_all({
            "event": "user_offline",
            "data": {
                "userId": user_id,
                "timestamp": datetime.utcnow().isoformat(),
            }
        })


async def handle_send_message(sender_id: str, sender_name: str, payload: dict):
    """Handle sending a chat message"""
    message_id = str(uuid.uuid4())
    recipient_id = payload.get("recipientId")
    room_id = payload.get("roomId")
    
    message = {
        "event": "message",
        "data": {
            "id": message_id,
            "content": payload.get("content", ""),
            "senderId": sender_id,
            "senderName": sender_name,
            "recipientId": recipient_id,
            "roomId": room_id,
            "orderId": payload.get("orderId"),
            "type": payload.get("type", "text"),
            "metadata": payload.get("metadata"),
            "timestamp": datetime.utcnow().isoformat(),
            "isDelivered": False,
            "isRead": False,
        }
    }
    
    # Send to room if room_id is specified
    if room_id:
        await manager.broadcast_to_room(message, room_id, exclude_user=sender_id)
    # Or send to specific recipient
    elif recipient_id:
        if manager.is_user_online(recipient_id):
            await manager.send_personal_message(message, recipient_id)
            # Send delivery confirmation
            await manager.send_personal_message({
                "event": "message_delivered",
                "data": {"messageId": message_id}
            }, sender_id)


async def handle_typing(sender_id: str, sender_name: str, payload: dict):
    """Handle typing indicator"""
    recipient_id = payload.get("recipientId")
    room_id = payload.get("roomId")
    is_typing = payload.get("isTyping", False)
    
    typing_event = {
        "event": "typing",
        "data": {
            "senderId": sender_id,
            "senderName": sender_name,
            "isTyping": is_typing,
        }
    }
    
    if room_id:
        await manager.broadcast_to_room(typing_event, room_id, exclude_user=sender_id)
    elif recipient_id:
        await manager.send_personal_message(typing_event, recipient_id)


async def handle_mark_read(reader_id: str, payload: dict):
    """Handle marking messages as read"""
    message_id = payload.get("messageId")
    sender_id = payload.get("senderId")
    
    if sender_id and manager.is_user_online(sender_id):
        await manager.send_personal_message({
            "event": "message_read",
            "data": {
                "messageId": message_id,
                "readerId": reader_id,
                "readAt": datetime.utcnow().isoformat(),
            }
        }, sender_id)


# REST endpoints for chat history and rooms

@router.get("/rooms/{user_id}")
async def get_user_chat_rooms(user_id: str, db: Session = Depends(get_db)):
    """Get all chat rooms for a user"""
    # This would query the database for chat rooms
    # For now, return mock data
    return {
        "rooms": [
            {
                "id": "room-1",
                "name": "Order #FB-8921",
                "orderId": "FB-8921",
                "lastMessage": {
                    "content": "Sample approved!",
                    "timestamp": datetime.utcnow().isoformat(),
                },
                "unreadCount": 2,
            },
            {
                "id": "room-2",
                "name": "Textile Partner",
                "lastMessage": {
                    "content": "Production update sent",
                    "timestamp": datetime.utcnow().isoformat(),
                },
                "unreadCount": 0,
            },
        ]
    }


@router.get("/history/{room_id}")
async def get_chat_history(
    room_id: str,
    limit: int = 50,
    before: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """Get chat history for a room"""
    # This would query the database for messages
    # For now, return mock data
    return {
        "roomId": room_id,
        "messages": [
            {
                "id": "msg-1",
                "content": "Hello, I'd like to discuss the order.",
                "senderId": "user-1",
                "senderName": "Buyer",
                "timestamp": "2026-01-05T10:00:00Z",
            },
            {
                "id": "msg-2",
                "content": "Sure! The production is on track.",
                "senderId": "user-2",
                "senderName": "Textile Partner",
                "timestamp": "2026-01-05T10:05:00Z",
            },
        ],
        "hasMore": False,
    }


@router.get("/online")
async def get_online_users():
    """Get list of currently online users"""
    return {
        "onlineUsers": manager.get_online_users(),
        "count": len(manager.get_online_users()),
    }
