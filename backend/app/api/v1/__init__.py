from fastapi import APIRouter

from app.api.v1.endpoints import auth, orders, ai, optimize, tracking, users, products, payments, workflow, chat, mcp

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(products.router, prefix="/products", tags=["Products & Services"])
api_router.include_router(orders.router, prefix="/orders", tags=["Orders"])
api_router.include_router(workflow.router, prefix="/workflow", tags=["Workflow & Orchestration"])
api_router.include_router(ai.router, prefix="/ai", tags=["AI Design Generation"])
api_router.include_router(optimize.router, prefix="/optimize", tags=["Optimization Engine"])
api_router.include_router(tracking.router, prefix="/tracking", tags=["Real-Time Tracking"])
api_router.include_router(payments.router, prefix="/payments", tags=["Payments"])
api_router.include_router(chat.router, prefix="", tags=["Chat"])
api_router.include_router(mcp.router, prefix="/mcp", tags=["MCP"])
from app.api.v1.endpoints import ai_services
api_router.include_router(ai_services.router, prefix="/ai-services", tags=["AI Engine"])
