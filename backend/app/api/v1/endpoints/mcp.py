from fastapi import APIRouter, Body
from typing import Dict, Any, List, Optional
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

# Global state to store the app state received from Flutter
app_state = {
    "screen": "unknown",
    "widgets": [],
    "data": {},
    "errors": []
}

# Queue for actions to be performed by the app
action_queue: List[Dict[str, Any]] = []

@router.post("/state")
async def update_state(state: Dict[str, Any] = Body(...)):
    """Update the current state of the Flutter app"""
    global app_state
    app_state = state
    logger.info(f"App state updated: {app_state['screen']}")
    return {"status": "success"}

@router.get("/state")
async def get_state():
    """Get the current state of the Flutter app"""
    return app_state

@router.get("/action")
async def get_action():
    """Poll for the next action to perform in the app"""
    if action_queue:
        action = action_queue.pop(0)
        return {"action": action}
    return {"action": None}

@router.post("/action")
async def add_action(action: Dict[str, Any] = Body(...)):
    """Add an action to the queue for the app to perform"""
    action_queue.append(action)
    logger.info(f"Action added to queue: {action}")
    return {"status": "success", "queue_size": len(action_queue)}

@router.post("/assert")
async def assert_state(assertion: Dict[str, Any] = Body(...)):
    """Verify if the current state matches the expected state"""
    target = assertion.get("target")
    expected_value = assertion.get("expected")
    
    # Simple assertion logic for now
    if target == "screen":
        success = app_state["screen"] == expected_value
        actual = app_state["screen"]
    else:
        # Check in data
        actual = app_state["data"].get(target)
        success = actual == expected_value
        
    return {
        "success": success,
        "actual": actual,
        "expected": expected_value
    }
