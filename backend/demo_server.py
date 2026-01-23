"""
FabricFlow - Simple Demo Server
This is a minimal version to test the API without database dependencies
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from enum import Enum

app = FastAPI(
    title="FabricFlow API",
    description="AI-Powered Supply Chain Platform for Fabric Industry",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Models
class UserRole(str, Enum):
    Buyer = "Buyer"
    MaterialVendor = "MaterialVendor"
    Factory = "Factory"
    Logistics = "Logistics"

class User(BaseModel):
    id: int
    role: UserRole
    name: str
    email: str

class LoginRequest(BaseModel):
    username: str
    password: str

class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: User

class AIDesignRequest(BaseModel):
    prompt: str
    fabric_type: str
    gsm: int
    quantity: int

class AIDesignResponse(BaseModel):
    design_url: str
    prompt_used: str
    bom: dict

# Routes
@app.get("/")
async def root():
    return {
        "message": "Welcome to FabricFlow API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs"
    }

@app.get("/api/v1/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "FabricFlow Backend",
        "python_version": "3.13"
    }

@app.post("/api/v1/auth/login")
async def login(request: LoginRequest):
    # Demo response
    return LoginResponse(
        access_token="demo_token_12345",
        user=User(
            id=1,
            role=UserRole.Buyer,
            name="Demo User",
            email=request.username
        )
    )

@app.post("/api/v1/auth/register")
async def register(user_data: dict):
    return {
        "message": "User registered successfully",
        "user_id": 1,
        "role": user_data.get("role", "Buyer")
    }

@app.post("/api/v1/ai/generate-design")
async def generate_design(request: AIDesignRequest):
    return AIDesignResponse(
        design_url=f"https://example.com/designs/{request.fabric_type}.png",
        prompt_used=f"{request.prompt} - {request.fabric_type} fabric, {request.gsm} GSM",
        bom={
            "fabric_type": request.fabric_type,
            "thread_kg": round(request.gsm * request.quantity / 1000 * 1.5, 2),
            "dye_kg": round(request.gsm * request.quantity / 10000, 2),
            "chemicals_kg": round(request.gsm * request.quantity / 10000 * 0.5, 2)
        }
    )

@app.get("/api/v1/orders/my-orders")
async def get_my_orders():
    return {
        "orders": [
            {
                "id": 1,
                "fabric_type": "Cotton",
                "quantity": 1000,
                "status": "Pending",
                "created_at": "2026-01-23T10:00:00Z"
            }
        ]
    }

@app.get("/api/v1/products")
async def get_products():
    return {
        "products": [
            {
                "id": 1,
                "name": "Cotton Thread - High Quality",
                "type": "Supply_Material",
                "price_per_unit": 150,
                "min_quantity": 100,
                "delivery_time_days": 7
            },
            {
                "id": 2,
                "name": "Textile Dyeing Service",
                "type": "Dyeing",
                "price_per_unit": 50,
                "min_quantity": 500,
                "delivery_time_days": 5
            }
        ]
    }

if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting FabricFlow API Server...")
    print("📝 API Documentation: http://localhost:8000/docs")
    print("🔗 Interactive API: http://localhost:8000/redoc")
    uvicorn.run("demo_server:app", host="0.0.0.0", port=8000, reload=True)
