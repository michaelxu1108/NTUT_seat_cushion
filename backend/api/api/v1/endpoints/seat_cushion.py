"""
座墊數據 API
"""
from fastapi import APIRouter, Depends, Query
from datetime import datetime
from typing import List, Optional
from core.mongodb import get_database

router = APIRouter()


@router.post("/data")
async def upload_seat_cushion_data(
    device_id: str,
    timestamp: datetime,
    forces: List[List[float]],
    cushion_type: str,  # "left" or "right"
    db=Depends(get_database)
):
    """上傳座墊壓力數據"""
    # TODO: 實作數據上傳
    # 1. 驗證數據格式
    # 2. 計算特徵（total_force, center_of_pressure 等）
    # 3. 儲存到 MongoDB
    # 4. 觸發 AI 分析（可選，異步）
    return {
        "message": "座墊數據上傳功能待實作",
        "device_id": device_id,
        "timestamp": timestamp
    }


@router.get("/data/history")
async def get_history_data(
    device_id: str,
    start_time: datetime = Query(...),
    end_time: datetime = Query(...),
    limit: int = Query(1000, le=10000),
    db=Depends(get_database)
):
    """查詢歷史座墊數據"""
    # TODO: 實作歷史數據查詢
    return {
        "message": "歷史數據查詢功能待實作",
        "device_id": device_id
    }


@router.get("/data/latest")
async def get_latest_data(
    device_id: str,
    db=Depends(get_database)
):
    """取得最新的座墊數據"""
    # TODO: 實作取得最新數據
    return {"message": "取得最新數據功能待實作"}


@router.get("/statistics")
async def get_statistics(
    device_id: str,
    start_time: datetime = Query(...),
    end_time: datetime = Query(...),
    db=Depends(get_database)
):
    """取得統計資訊"""
    # TODO: 實作統計資訊
    # - 平均坐姿評分
    # - 坐姿分布
    # - 使用時長
    return {"message": "統計資訊功能待實作"}
