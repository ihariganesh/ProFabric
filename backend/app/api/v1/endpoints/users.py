from fastapi import APIRouter

router = APIRouter()

# Placeholder - implement as needed
@router.get("/user/{user_id}")
async def get_user(user_id: int):
    return {"message": "User endpoint - to be implemented"}
