"""
特徵工程：從原始數據提取特徵
"""
import numpy as np
from typing import List, Dict, Tuple


def extract_pressure_features(forces: List[List[float]]) -> Dict[str, float]:
    """
    從座墊壓力矩陣提取特徵

    Args:
        forces: 31x8 的壓力矩陣

    Returns:
        特徵字典
    """
    forces_array = np.array(forces)

    # 基本統計特徵
    features = {
        # 總壓力
        "total_force": float(np.sum(forces_array)),
        "max_force": float(np.max(forces_array)),
        "min_force": float(np.min(forces_array)),
        "mean_force": float(np.mean(forces_array)),
        "median_force": float(np.median(forces_array)),
        "std_force": float(np.std(forces_array)),

        # 壓力分布
        "non_zero_ratio": float(np.count_nonzero(forces_array) / forces_array.size),
        "high_pressure_ratio": float(np.sum(forces_array > 100) / forces_array.size),
    }

    # 壓力中心 (Center of Pressure)
    cop_x, cop_y = calculate_center_of_pressure(forces_array)
    features["cop_x"] = cop_x
    features["cop_y"] = cop_y

    # 左右不平衡度
    left_right_balance = calculate_left_right_balance(forces_array)
    features["left_right_balance"] = left_right_balance

    # 前後不平衡度
    front_back_balance = calculate_front_back_balance(forces_array)
    features["front_back_balance"] = front_back_balance

    # TODO: 更多特徵
    # - 壓力峰值位置
    # - 壓力分散度
    # - 接觸面積

    return features


def calculate_center_of_pressure(
    forces: np.ndarray
) -> Tuple[float, float]:
    """計算壓力中心座標"""
    rows, cols = forces.shape
    total_force = np.sum(forces)

    if total_force == 0:
        return 0.0, 0.0

    # 計算加權平均
    x_coords = np.arange(cols)
    y_coords = np.arange(rows)

    cop_x = float(np.sum(np.sum(forces, axis=0) * x_coords) / total_force)
    cop_y = float(np.sum(np.sum(forces, axis=1) * y_coords) / total_force)

    return cop_x, cop_y


def calculate_left_right_balance(forces: np.ndarray) -> float:
    """
    計算左右平衡度

    Returns:
        -1.0 到 1.0，0 表示平衡
        負值表示左側壓力較大，正值表示右側壓力較大
    """
    cols = forces.shape[1]
    mid_col = cols // 2

    left_pressure = np.sum(forces[:, :mid_col])
    right_pressure = np.sum(forces[:, mid_col:])

    total = left_pressure + right_pressure
    if total == 0:
        return 0.0

    return float((right_pressure - left_pressure) / total)


def calculate_front_back_balance(forces: np.ndarray) -> float:
    """
    計算前後平衡度

    Returns:
        -1.0 到 1.0，0 表示平衡
        負值表示前側壓力較大，正值表示後側壓力較大
    """
    rows = forces.shape[0]
    mid_row = rows // 2

    front_pressure = np.sum(forces[:mid_row, :])
    back_pressure = np.sum(forces[mid_row:, :])

    total = front_pressure + back_pressure
    if total == 0:
        return 0.0

    return float((back_pressure - front_pressure) / total)
