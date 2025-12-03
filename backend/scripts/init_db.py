"""
初始化資料庫：創建索引、初始數據
"""
from pymongo import MongoClient, ASCENDING, DESCENDING
import os
from dotenv import load_dotenv

load_dotenv()


def init_database():
    """初始化資料庫"""
    # 連接 MongoDB
    mongodb_url = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
    db_name = os.getenv("MONGODB_DB_NAME", "medical_system")

    client = MongoClient(mongodb_url)
    db = client[db_name]

    print(f"📦 初始化資料庫: {db_name}")

    # 創建 users collection 索引
    print("創建 users 索引...")
    db.users.create_index([("email", ASCENDING)], unique=True)
    db.users.create_index([("role", ASCENDING)])

    # 創建 devices collection 索引
    print("創建 devices 索引...")
    db.devices.create_index([("device_id", ASCENDING)], unique=True)
    db.devices.create_index([("owner_id", ASCENDING)])
    db.devices.create_index([("device_type", ASCENDING)])

    # 創建 seat_cushion_data collection 索引
    print("創建 seat_cushion_data 索引...")
    db.seat_cushion_data.create_index([("device_id", ASCENDING), ("timestamp", DESCENDING)])
    db.seat_cushion_data.create_index([("user_id", ASCENDING), ("timestamp", DESCENDING)])
    db.seat_cushion_data.create_index([("session_id", ASCENDING)])
    # TTL 索引：1年後自動刪除
    db.seat_cushion_data.create_index(
        [("created_at", ASCENDING)],
        expireAfterSeconds=31536000
    )

    # 創建 sensor_data collection 索引
    print("創建 sensor_data 索引...")
    db.sensor_data.create_index([("device_id", ASCENDING), ("timestamp", DESCENDING)])
    db.sensor_data.create_index([("sensor_type", ASCENDING)])

    # 創建 sessions collection 索引
    print("創建 sessions 索引...")
    db.sessions.create_index([("user_id", ASCENDING), ("start_time", DESCENDING)])
    db.sessions.create_index([("device_id", ASCENDING)])

    # 創建 analysis_results collection 索引
    print("創建 analysis_results 索引...")
    db.analysis_results.create_index([("user_id", ASCENDING), ("period.end", DESCENDING)])

    print("✅ 資料庫初始化完成！")
    print(f"\n資料庫名稱: {db_name}")
    print(f"Collections: {db.list_collection_names()}")


if __name__ == "__main__":
    init_database()
