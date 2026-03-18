# Multi-Role Architecture & Workflow Engine

## User Roles
* **Buyer**: Submits designs, evaluates cost/timeline and sustainability scores, approves samples, and tracks full pipeline.
* **Textile Hub (Orchestrator)**: System moderator, handles routing, assigns tasks if auto-assignment falls back, and manages quality gates.
* **Supply Partner**: 
  - Yarn Manufacturer
  - Weaver
  - Fabric Seller
  - Printing Unit
  - Stitching Unit
  - Logistics Provider
* **Admin**: Platform oversight, user management, dispute resolution.

## Workflow Engine
The platform implements a stringent event-driven workflow.

### Stages
1. **CREATED**: Buyer uploads design and requirements. 
2. **SAMPLE_REQUESTED**: Textile hub routes to partner.
3. **SAMPLE_SENT**: Partner sends sample.
4. **SAMPLE_APPROVED**: Buyer approves digitial or physical sample.
5. **FABRIC_SOURCED**: Sub-tasks for yarn/weaving/fabric sellers are fulfilled.
6. **PRINTING**: Fabric moved to printing unit.
7. **STITCHING**: Fabric moved to stitching unit.
8. **PACKAGING**: Quality checked via EdgeGuard -> packed.
9. **SHIPPED**: Logistics partner takes control.
10. **DELIVERED**: Final validation.

### Transitions & Guards
- `CREATED` -> `SAMPLE_REQUESTED`: Triggers FabricSim & EcoFlow for optimal partner matching.
- `PRINTING` & `STITCHING`: EdgueGuard live quality CV models run continuously here.
- `SHIPPED`: Logistics Provider accepts shipment, real-time location streaming is initiated.

## Backend Modular Service Map
- `app/services/workflow_engine.py`: Defines the strict FSM (Finite State Machine) for order lifecycle. Publishes events (e.g. RabbitMQ/Redis).
- `app/services/ai/ecoflow.py`: NSGA-II multiobjective optimizer for cost vs. sustainability.
- `app/services/ai/riskradar.py`: Celery/Queue-based background crawler calling News/Weather APIs for real-time risk scores (Random Forest/LLM NLP classification).
- `app/services/ai/fabricsim.py`: Predictive analytics forecasting delays and bottleneck likelihood using historical digital twins.
- `app/services/ai/edgeguard.py`: YOLOv8-based CV service, ingests frame segments from partners and yields heatmap anomalies.

## API Contracts
* **POST /api/v1/orders**: Initiates workflow.
* **POST /api/v1/ai/simulate**: Returns `FabricSim` run.
* **POST /api/v1/ai/ecoflow**: Takes order configuration, returns scored suppliers.
* **POST /api/v1/ai/edgeguard/detect**: Takes Base64/Image URL, returns YOLO coordinates of defects.
