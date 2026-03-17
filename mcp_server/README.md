# ProFabric MCP Agent Server

This is the Model Context Protocol (MCP) server integration designed to enable autonomous AI agents to test and interact with the ProFabric Flutter app continuously.

## Phase 1 & 2: Architecture & Bridge Implementation

This repository consists of two integrated pieces:
1. **The Python FastAPI MCP Server (`mcp_server/main.py`)**: Exposes MCP schema tools (`get_state`, `perform_action`, `assert_state`) via stdio for AI integration while simultaneously running a REST interface on `127.0.0.1:8000`.
2. **The Flutter McpBridge (`frontend/lib/core/services/mcp_bridge.dart`)**: Lives directly in the Dart application memory. It continuously reports the app's current semantic state (active screen, available widgets, form data payloads) and polls for execution requests from the AI agent loop.

## Phase 3: Tool Interfaces

**`get_state()`**
Returns a serialized string of the current app footprint.
`{'screen': 'login_screen', 'widgets': ['email_input', 'password_input', 'login_button', 'switch_auth_mode'], 'data': {}, 'errors': []}`

**`perform_action(action: str, target: str, value: str = "")`**
Dispatches interaction commands asynchronously to the running app.
- `action`: Type of action (`tap`, `input_text`)
- `target`: The widget ID (e.g., `email_input`)
- `value`: The payload (e.g., `test@example.com`)

**`assert_state(target: str, expected_value: str)`**
The verification protocol. Checks `target` against `expected_value` and returns a human-readable assertion failure/pass reason.

---

## Phase 4: Example Autonomous Agent Testing Flow

Below is a successful login flow mapping:

1. **Agent Step 1:** `<call:get_state>`
   **Response:** `{"screen": "login_screen", "widgets": ["email_input", "password_input", "login_button"], "data": {}, "errors": []}`

2. **Agent Step 2:** `<call:perform_action(action="input_text", target="email_input", value="buyer@test.com")>`
   **Response:** `Action queued.`

3. **Agent Step 3:** `<call:perform_action(action="input_text", target="password_input", value="123456")>`
   **Response:** `Action queued.`

4. **Agent Step 4:** `<call:perform_action(action="tap", target="login_button")>`
   **Response:** `Action queued.`

5. **Agent Step 5:** `<call:assert_state(target="screen", expected_value="dashboard_screen")>`
   **Response:** `Assertion passed` *(if navigation succeeded)* OR `Assertion failed: expected dashboard_screen, got login_screen.`

---

## Phase 5 & 6: Found Issues & Autonomous Development Suggestions

### Issue Detected: Form State Blindness
- **Reproduction:** Agent enters email text, but `get_state()` still shows `"data": {}` because the `McpBridge` was registered but text controllers weren't actively hooking into `McpBridge.instance.updateData`.
- **File:** `login_screen.dart`
- **Suggested Minimal Fix:** Add a listener to `_emailController`: 
  ```dart
  _emailController.addListener(() {
     McpBridge.instance.updateData('email', _emailController.text);
  });
  ```
- **Risk Level:** Very Low

### Issue Detected: Hardcoded IP in Emulator Runs
- **Reproduction:** When testing on the Android Emulator, `127.0.0.1` binds to the emulator itself instead of the host machine running the MCP server, causing network timeouts.
- **Suggested Minimal Fix:** Alter `main.dart` to use `McpBridge.instance.start(apiUrl: "http://10.0.2.2:8000");` for Android.

## Phase 7: Next Steps & Enhancements

Once the core interaction pipeline is stabilized across all screens, we can introduce:
- **WebSocket Streaming:** Replace the 1-second REST polling cycle with a persistent WebSocket connection to eliminate latency.
- **Tree Crawler:** Use Flutter's `SemanticsBinding` to automatically discover interactive `Semantics` nodes instead of manually registering them via `McpBridge.instance.registerWidget()`.
