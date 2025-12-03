"""
使用者管理 API
"""
from fastapi import APIRouter, Depends
from core.mongodb import get_database

router = APIRouter()


@router.get("/")
async def list_users(
    skip: int = 0,
    limit: int = 100,
    db=Depends(get_database)
):
    """列出所有使用者"""
    # TODO: 實作使用者列表
    return {"message": "使用者列表功能待實作"}


@router.get("/{user_id}")
async def get_user(user_id: str, db=Depends(get_database)):
    """取得特定使用者資訊"""
    # TODO: 實作取得使用者資訊
    return {"message": f"取得使用者 {user_id} 資訊功能待實作"}


@router.put("/{user_id}")
async def update_user(
    user_id: str,
    name: str = None,
    db=Depends(get_database)
):
    """更新使用者資訊"""
    # TODO: 實作更新使用者資訊
    return {"message": "更新使用者資訊功能待實作"}
