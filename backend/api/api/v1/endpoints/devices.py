"""
設備管理 API
"""
from fastapi import APIRouter, Depends
from core.mongodb import get_database

router = APIRouter()


@router.get("/")
async def list_devices(db=Depends(get_database)):
    """列出所有設備"""
    # TODO: 實作設備列表
    return {"message": "設備列表功能待實作"}


@router.post("/")
async def register_device(
    device_id: str,
    device_type: str,
    name: str,
    db=Depends(get_database)
):
    """註冊新設備"""
    # TODO: 實作設備註冊
    return {"message": "設備註冊功能待實作"}


@router.get("/{device_id}")
async def get_device(device_id: str, db=Depends(get_database)):
    """取得特定設備資訊"""
    # TODO: 實作取得設備資訊
    return {"message": f"取得設備 {device_id} 資訊功能待實作"}
