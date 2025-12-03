"""
MongoDB 連接管理
"""
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import MongoClient
from core.config import settings

# 非同步客戶端（用於 FastAPI）
async_client: AsyncIOMotorClient = None
async_db = None

# 同步客戶端（用於腳本和初始化）
sync_client: MongoClient = None
sync_db = None


async def connect_to_mongo():
    """連接到 MongoDB"""
    global async_client, async_db
    async_client = AsyncIOMotorClient(settings.MONGODB_URL)
    async_db = async_client[settings.MONGODB_DB_NAME]
    print(f"✅ Connected to MongoDB: {settings.MONGODB_DB_NAME}")


async def close_mongo_connection():
    """關閉 MongoDB 連接"""
    global async_client
    if async_client:
        async_client.close()
        print("✅ MongoDB connection closed")


def get_sync_db():
    """取得同步資料庫（用於腳本）"""
    global sync_client, sync_db
    if not sync_client:
        sync_client = MongoClient(settings.MONGODB_URL)
        sync_db = sync_client[settings.MONGODB_DB_NAME]
    return sync_db


async def get_database():
    """依賴注入：取得資料庫實例"""
    return async_db
