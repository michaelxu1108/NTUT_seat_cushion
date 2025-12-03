"""
感測器數據 API（溫度、ECG 等）
"""
from fastapi import APIRouter, Depends
from datetime import datetime
from typing import Dict, Any
from core.mongodb import get_database

router = APIRouter()


@router.post("/data")
async def upload_sensor_data(
    device_id: str,
    sensor_type: str,  # "temperature", "ecg", "impedance"
    timestamp: datetime,
    values: Dict[str, Any],
    db=Depends(get_database)
):
    """上傳感測器數據"""
    # TODO: 實作感測器數據上傳
    return {
        "message": "感測器數據上傳功能待實作",
        "sensor_type": sensor_type
    }


@router.get("/data/history")
async def get_sensor_history(
    device_id: str,
    sensor_type: str,
    start_time: datetime,
    end_time: datetime,
    db=Depends(get_database)
):
    """查詢感測器歷史數據"""
    # TODO: 實作歷史數據查詢
    return {"message": "感測器歷史數據查詢功能待實作"}
