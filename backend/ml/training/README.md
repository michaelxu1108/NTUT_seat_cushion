# ML 模型訓練

此資料夾包含機器學習模型的訓練腳本和 Jupyter notebooks。

## 檔案結構

```
training/
├── notebooks/              # Jupyter notebooks
│   ├── 01_data_exploration.ipynb     # 數據探索
│   ├── 02_feature_engineering.ipynb  # 特徵工程
│   ├── 03_model_training.ipynb       # 模型訓練
│   └── 04_model_evaluation.ipynb     # 模型評估
│
├── train_posture.py        # 坐姿分類模型訓練
├── train_anomaly.py        # 異常偵測模型訓練
└── train_predictor.py      # 健康風險預測模型訓練
```

## 訓練流程

### 1. 數據收集

首先需要收集標註數據：
- 收集不同坐姿的座墊壓力數據
- 由專業人員標註坐姿類別
- 建議至少 1000 筆標註數據

### 2. 數據探索

使用 `01_data_exploration.ipynb` 探索數據：
- 數據分布
- 異常值檢測
- 類別平衡

### 3. 特徵工程

使用 `02_feature_engineering.ipynb` 設計特徵：
- 壓力統計特徵
- 幾何特徵
- 時序特徵

### 4. 模型訓練

```bash
# 訓練坐姿分類模型
python train_posture.py --data /path/to/data --output ../models/

# 訓練異常偵測模型
python train_anomaly.py --data /path/to/data --output ../models/
```

### 5. 模型評估

使用 `04_model_evaluation.ipynb` 評估模型性能：
- 準確率
- 混淆矩陣
- ROC 曲線

## TODO

- [ ] 收集標註數據
- [ ] 實作訓練腳本
- [ ] 模型性能優化
- [ ] 模型部署流程
