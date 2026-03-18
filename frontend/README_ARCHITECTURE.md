# Frontend Architecture: AI-Driven Textile Platform

## State Management & Roles
The application fundamentally branches at the root based on the authenticated User's Role. 
We employ modular dashboards per role:
* **Buyer**: `lib/features/buyer/dashboard/`
* **Textile Hub**: `lib/features/hub/dashboard/`
* **Supply Partner**: `lib/features/partner/dashboard/`
* **Logistics**: `lib/features/logistics/dashboard/`
* **Admin**: `lib/features/admin/dashboard/`

## Core Workflow UI
* **Order Timeline Stepper**: A globally shared visual stepper indicating the order's state (`CREATED` → `DELIVERED`). Real-time WebSockets connect to the back-end FSM.

## AI Feature Integrations

### 1. EcoFlow
* **UI**: Toggle switch on the Buyer’s New Order view (`"Eco-Friendly Mode"`).
* **Visualization**: When active, supplier cards emphasize their sustainability scores and CO2 carbon offset metrics.

### 2. FabricSim
* **UI**: Button "Simulate Run" on checkout/order summary screen.
* **Visualization**: Triggers bottom sheet or dialog rendering an animated timeline graphic showing predicted delays, bottlenecks, and the generated risk score prior to order commitment.

### 3. EdgeGuard Dashboard
* **Buyer UI**: Quality Control tab on the active order screen. Streams WebSocket events of "EdgeGuard Anomalies". Shows heatmap images of fabric defects natively using `NetworkImage`.
* **Partner UI**: "Upload QC Feed" button allowing device camera access to ingest into YOLO models.

### 4. RiskRadar
* **UI**: Visible heavily on the Admin and Textile Hub monitoring screens. Flags suppliers with an amber/red warning icon pulling live textual NLP reasons (e.g. "Maritime strike expected").

## Communication Interface
* REST for static/CRUD actions (Order creation, Profile).
* WebSockets/gRPC for event-driven states (Order State transitions, EdgeGuard live frames, RiskRadar sudden alerts).
