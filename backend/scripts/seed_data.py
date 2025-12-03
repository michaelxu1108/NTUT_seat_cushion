"""
種子數據：創建測試用戶和設備
"""
from pymongo import MongoClient
from datetime import datetime
import os
from dotenv import load_dotenv
import sys
sys.path.append('..')
from api.core.security import get_password_hash

load_dotenv()


def seed_data():
    """創建種子數據"""
    # 連接 MongoDB
    mongodb_url = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
    db_name = os.getenv("MONGODB_DB_NAME", "medical_system")

    client = MongoClient(mongodb_url)
    db = client[db_name]

    print("🌱 開始創建種子數據...")

    # 創建測試使用者
    users = [
        {
            "email": "doctor@example.com",
            "password_hash": get_password_hash("password123"),
            "role": "doctor",
            "profile": {
                "name": "王醫師",
                "hospital": "台北榮總",
                "department": "復健科"
            },
            "created_at": datetime.utcnow()
        },
        {
            "email": "patient@example.com",
            "password_hash": get_password_hash("password123"),
            "role": "patient",
            "profile": {
                "name": "張先生",
                "age": 45
            },
            "created_at": datetime.utcnow()
        }
    ]

    print("創建測試使用者...")
    for user in users:
        existing = db.users.find_one({"email": user["email"]})
        if not existing:
            result = db.users.insert_one(user)
            print(f"  ✅ 創建使用者: {user['email']} (ID: {result.inserted_id})")
        else:
            print(f"  ⚠️  使用者已存在: {user['email']}")

    # 創建測試設備
    patient_id = db.users.find_one({"email": "patient@example.com"})["_id"]

    devices = [
        {
            "device_id": "SEAT_001",
            "device_type": "seat_cushion",
            "owner_id": patient_id,
            "name": "座墊感測器 #1",
            "status": "active",
            "metadata": {
                "mac_address": "AA:BB:CC:DD:EE:FF",
                "firmware_version": "1.0.0"
            },
            "created_at": datetime.utcnow()
        },
        {
            "device_id": "AD5940_001",
            "device_type": "ad5940",
            "owner_id": patient_id,
            "name": "溫度感測器 #1",
            "status": "active",
            "metadata": {
                "mac_address": "11:22:33:44:55:66",
                "firmware_version": "1.0.0"
            },
            "created_at": datetime.utcnow()
        }
    ]

    print("創建測試設備...")
    for device in devices:
        existing = db.devices.find_one({"device_id": device["device_id"]})
        if not existing:
            result = db.devices.insert_one(device)
            print(f"  ✅ 創建設備: {device['device_id']} (ID: {result.inserted_id})")
        else:
            print(f"  ⚠️  設備已存在: {device['device_id']}")

    print("\n✅ 種子數據創建完成！")
    print("\n測試帳號：")
    print("  醫生: doctor@example.com / password123")
    print("  病患: patient@example.com / password123")


if __name__ == "__main__":
    seed_data()
