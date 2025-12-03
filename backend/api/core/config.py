"""
應用程式配置
"""
from pydantic_settings import BaseSettings
from typing import List, Optional


class Settings(BaseSettings):
    # 專案資訊
    PROJECT_NAME: str = "NTUT UTL Medical System"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"

    # CORS 設定
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost",
        "http://localhost:8080",
        "http://localhost:3000",
        # 加入你的 Flutter app 位址
    ]

    # MongoDB 設定
    MONGODB_URL: str = "mongodb://localhost:27017"
    MONGODB_DB_NAME: str = "medical_system"

    # JWT 設定
    SECRET_KEY: str = "your-secret-key-change-this-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    # AWS 設定（可選）
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_REGION: Optional[str] = "ap-northeast-1"
    S3_BUCKET_NAME: Optional[str] = None

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
