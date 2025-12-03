"""
API v1 路由匯總
"""
from fastapi import APIRouter
from api.v1.endpoints import auth, users, seat_cushion, sensors, devices, analysis

api_router = APIRouter()

# 註冊各個端點路由
api_router.include_router(auth.router, prefix="/auth", tags=["認證"])
api_router.include_router(users.router, prefix="/users", tags=["使用者"])
api_router.include_router(devices.router, prefix="/devices", tags=["設備"])
api_router.include_router(
    seat_cushion.router,
    prefix="/seat-cushion",
    tags=["座墊數據"]
)
api_router.include_router(sensors.router, prefix="/sensors", tags=["感測器"])
api_router.include_router(analysis.router, prefix="/analysis", tags=["AI 分析"])
