"""
座姿分析器
"""
import numpy as np
from typing import List, Dict, Any
import pickle
import os


class PostureAnalyzer:
    """座姿分析 AI 模型"""

    def __init__(self, model_path: str = None):
        """初始化分析器"""
        self.model = None
        self.model_loaded = False

        if model_path and os.path.exists(model_path):
            self.load_model(model_path)

    def load_model(self, model_path: str):
        """載入訓練好的模型"""
        try:
            with open(model_path, 'rb') as f:
                self.model = pickle.load(f)
            self.model_loaded = True
            print(f"✅ Model loaded from {model_path}")
        except Exception as e:
            print(f"❌ Failed to load model: {e}")

    def analyze(self, forces: List[List[float]]) -> Dict[str, Any]:
        """
        分析座墊壓力數據

        Args:
            forces: 31x8 的壓力矩陣

        Returns:
            分析結果字典，包含：
            - posture: 坐姿類別
            - confidence: 信心分數
            - health_score: 健康評分 (0-100)
            - risk_level: 風險等級
            - recommendations: 建議列表
        """
        # 特徵提取
        features = self._extract_features(forces)

        # 如果模型未載入，使用規則based方法
        if not self.model_loaded:
            return self._rule_based_analysis(features)

        # 使用 ML 模型預測
        # TODO: 實作模型預測邏輯
        posture = self._predict_posture(features)
        health_score = self._calculate_health_score(features, posture)

        return {
            "posture": posture,
            "confidence": 0.85,  # TODO: 從模型取得
            "health_score": health_score,
            "risk_level": self._assess_risk(health_score),
            "recommendations": self._generate_recommendations(posture, health_score)
        }

    def _extract_features(self, forces: List[List[float]]) -> Dict[str, float]:
        """從壓力矩陣提取特徵"""
        forces_array = np.array(forces)

        return {
            "total_force": float(np.sum(forces_array)),
            "max_force": float(np.max(forces_array)),
            "mean_force": float(np.mean(forces_array)),
            "std_force": float(np.std(forces_array)),
            "non_zero_ratio": float(np.count_nonzero(forces_array) / forces_array.size),
            # TODO: 更多特徵
            # - 壓力中心座標
            # - 左右不平衡度
            # - 前後不平衡度
        }

    def _rule_based_analysis(self, features: Dict[str, float]) -> Dict[str, Any]:
        """基於規則的分析（當 ML 模型未載入時使用）"""
        total_force = features["total_force"]

        # 簡單的規則判斷
        if total_force < 500:
            posture = "no_pressure"
            health_score = 0
        elif total_force > 2000:
            posture = "heavy_pressure"
            health_score = 50
        else:
            posture = "normal"
            health_score = 75

        return {
            "posture": posture,
            "confidence": 0.6,
            "health_score": health_score,
            "risk_level": self._assess_risk(health_score),
            "recommendations": self._generate_recommendations(posture, health_score)
        }

    def _predict_posture(self, features: Dict[str, float]) -> str:
        """預測坐姿類別"""
        # TODO: 實作 ML 模型預測
        # posture_classes = ["good", "slouching", "leaning_left", "leaning_right"]
        return "good"

    def _calculate_health_score(
        self,
        features: Dict[str, float],
        posture: str
    ) -> int:
        """計算健康評分 (0-100)"""
        # TODO: 實作評分邏輯
        base_score = 80

        # 根據坐姿調整分數
        posture_penalty = {
            "good": 0,
            "slouching": -15,
            "leaning_left": -10,
            "leaning_right": -10,
            "heavy_pressure": -20
        }

        score = base_score + posture_penalty.get(posture, -5)
        return max(0, min(100, score))

    def _assess_risk(self, health_score: int) -> str:
        """評估風險等級"""
        if health_score >= 75:
            return "low"
        elif health_score >= 50:
            return "medium"
        else:
            return "high"

    def _generate_recommendations(
        self,
        posture: str,
        health_score: int
    ) -> List[str]:
        """生成健康建議"""
        recommendations = []

        if posture == "slouching":
            recommendations.append("建議調整坐姿，挺直背部")
            recommendations.append("考慮使用腰靠支撐")

        if posture in ["leaning_left", "leaning_right"]:
            recommendations.append("注意身體重心，避免長時間單側傾斜")

        if health_score < 60:
            recommendations.append("建議每 30 分鐘起身活動一次")

        if not recommendations:
            recommendations.append("目前坐姿良好，請保持")

        return recommendations


# 單例模式
_analyzer_instance = None


def get_analyzer() -> PostureAnalyzer:
    """取得分析器實例"""
    global _analyzer_instance
    if _analyzer_instance is None:
        _analyzer_instance = PostureAnalyzer()
    return _analyzer_instance
