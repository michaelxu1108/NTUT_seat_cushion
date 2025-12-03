"""
AI 分析結果 API
"""
from fastapi import APIRouter, Depends, Query
from datetime import datetime
from core.mongodb import get_database

router = APIRouter()


@router.get("/latest")
async def get_latest_analysis(
    device_id: str,
    db=Depends(get_database)
):
    """取得最新的 AI 分析結果"""
    # TODO: 實作取得最新分析結果
    # 返回：坐姿評估、健康評分、建議
    return {"message": "最新分析結果功能待實作"}


@router.get("/report")
async def get_analysis_report(
    user_id: str,
    report_type: str = Query("weekly", regex="^(daily|weekly|monthly)$"),
    start_time: datetime = Query(...),
    end_time: datetime = Query(...),
    db=Depends(get_database)
):
    """取得分析報告"""
    # TODO: 實作分析報告
    # - 每日/每週/每月報告
    # - 坐姿趨勢
    # - 健康風險評估
    return {
        "message": "分析報告功能待實作",
        "report_type": report_type
    }


@router.post("/trigger")
async def trigger_analysis(
    data_id: str,
    db=Depends(get_database)
):
    """手動觸發 AI 分析"""
    # TODO: 實作手動觸發分析
    # 用於重新分析歷史數據
    return {"message": "手動觸發分析功能待實作"}
