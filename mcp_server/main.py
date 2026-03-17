import sys
import threading
import logging
from fastapi import FastAPI, Request
from pydantic import BaseModel
import uvicorn

try:
    from mcp.server.fastmcp import FastMCP
except ImportError:
    print("mcp package is required. pip install mcp")
    sys.exit(1)

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger("mcp_server")

current_app_state = {
    "screen": "unknown",
    "widgets": [],
    "data": {},
    "errors": []
}

pending_actions = []

class AppState(BaseModel):
    screen: str
    widgets: list[str]
    data: dict
    errors: list[str] = []

app = FastAPI()

@app.post("/app/state")
async def update_state(state: AppState):
    global current_app_state
    current_app_state = state.model_dump()
    return {"status": "success"}

@app.get("/app/action")
async def get_action():
    if pending_actions:
        return {"action": pending_actions.pop(0)}
    return {"action": None}

@app.get("/state")
async def get_state_endpoint():
    return current_app_state

@app.post("/assert")
async def assert_endpoint(assertion: dict):
    target = assertion.get("target")
    expected_value = assertion.get("value")
    if target == "screen":
        success = current_app_state.get("screen") == expected_value
    else:
        success = expected_value in current_app_state.get("widgets", [])
    reason = "Assertion passed" if success else f"Assertion failed: expected {expected_value}, got {current_app_state.get('screen')}"
    return {"success": success, "reason": reason}

mcp = FastMCP("ProFabric Test Agent")

@mcp.tool()
def get_state() -> str:
    """Returns the current state of the Flutter app, including screen, widgets, and data."""
    return str(current_app_state)

@mcp.tool()
def perform_action(action: str, target: str, value: str = "") -> str:
    """
    Performs an action on the Flutter app.
    Supported actions: tap, input_text, navigate, submit.
    """
    act = {"action": action, "target": target, "value": value}
    pending_actions.append(act)
    logger.info(f"MCP Action queued: {act}")
    return f"Action queued: {act}. Please wait a moment and check state again."

@mcp.tool()
def assert_state(target: str, expected_value: str) -> str:
    """
    Asserts a condition in the app state.
    target: 'screen' or 'widget'
    expected_value: e.g., 'login_screen'
    """
    if target == "screen":
        success = current_app_state.get("screen") == expected_value
    else:
        success = expected_value in current_app_state.get("widgets", [])
    reason = "Assertion passed" if success else f"Assertion failed: expected {expected_value}, current screen {current_app_state.get('screen')}"
    return reason

def run_fastapi():
    uvicorn.run(app, host="127.0.0.1", port=8000, log_level="warning")

if __name__ == "__main__":
    t = threading.Thread(target=run_fastapi, daemon=True)
    t.start()
    mcp.run()
