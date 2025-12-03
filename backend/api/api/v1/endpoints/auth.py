"""
認證相關 API
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from core.security import verify_password, create_access_token
from core.mongodb import get_database

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


@router.post("/register")
async def register(
    email: str,
    password: str,
    name: str,
    role: str = "patient",
    db=Depends(get_database)
):
    """使用者註冊"""
    # TODO: 實作註冊邏輯
    return {"message": "註冊功能待實作"}


@router.post("/login")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db=Depends(get_database)
):
    """使用者登入"""
    # TODO: 實作登入邏輯
    # 1. 驗證使用者帳號密碼
    # 2. 生成 JWT token
    # 3. 返回 token
    return {"access_token": "dummy-token", "token_type": "bearer"}


@router.get("/me")
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db=Depends(get_database)
):
    """取得當前使用者資訊"""
    # TODO: 實作取得使用者資訊
    return {"message": "取得使用者資訊功能待實作"}
