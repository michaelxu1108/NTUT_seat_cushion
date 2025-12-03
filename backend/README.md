# NTUT UTL 醫療監測系統 - 後端

Python FastAPI 後端服務，提供醫療感測器數據儲存、查詢和 AI 分析功能。

## 功能特色

- 🏥 **醫療數據管理** - 儲存和查詢座墊、溫度等感測器數據
- 🤖 **AI 智能分析** - 自動分析坐姿、健康風險評估
- 👥 **多使用者系統** - 支援醫生、病患等不同角色
- 📊 **歷史數據分析** - 長期趨勢分析和健康報告
- 🔒 **安全認證** - JWT token 認證機制
- 📱 **RESTful API** - 與 Flutter 前端無縫整合

## 技術棧

- **FastAPI** - 現代、高效能的 Python Web 框架
- **MongoDB** - NoSQL 資料庫，適合時序數據
- **Motor** - MongoDB 非同步驅動
- **scikit-learn** - 機器學習模型
- **Docker** - 容器化部署

## 專案結構

```
backend/
├── api/                        # FastAPI 應用
│   ├── main.py                # 主應用入口
│   ├── api/v1/                # API v1 路由
│   │   ├── endpoints/         # API 端點
│   │   │   ├── auth.py        # 認證
│   │   │   ├── users.py       # 使用者管理
│   │   │   ├── devices.py     # 設備管理
│   │   │   ├── seat_cushion.py # 座墊數據
│   │   │   ├── sensors.py     # 感測器數據
│   │   │   └── analysis.py    # AI 分析
│   │   └── api.py             # 路由匯總
│   ├── core/                  # 核心功能
│   │   ├── config.py          # 配置
│   │   ├── mongodb.py         # 資料庫連接
│   │   └── security.py        # 安全功能
│   ├── models/                # Pydantic 模型
│   ├── schemas/               # API schemas
│   └── services/              # 業務邏輯
│
├── ml/                        # ML/AI 模組
│   ├── models/                # 訓練好的模型
│   ├── training/              # 訓練腳本
│   ├── inference/             # 推論服務
│   │   └── posture_analyzer.py # 座姿分析器
│   └── preprocessing/         # 數據預處理
│       └── feature_engineer.py # 特徵工程
│
├── tests/                     # 測試
├── scripts/                   # 工具腳本
├── docker/                    # Docker 配置
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── requirements.txt           # Python 依賴
├── requirements-ml.txt        # ML 依賴
└── .env.example              # 環境變數範例
```

## 快速開始

### 1. 環境準備

```bash
# 確保已安裝 Python 3.11+
python --version

# 進入後端目錄
cd backend
```

### 2. 安裝依賴

```bash
# 創建虛擬環境
python -m venv venv

# 啟動虛擬環境
# macOS/Linux:
source venv/bin/activate
# Windows:
venv\Scripts\activate

# 安裝 API 依賴
pip install -r requirements.txt

# （可選）安裝 ML 依賴
pip install -r requirements-ml.txt
```

### 3. 設定環境變數

```bash
# 複製範例環境變數檔案
cp .env.example .env

# 編輯 .env，設定你的 MongoDB 連接等
vim .env
```

### 4. 啟動 MongoDB

#### 選項 A：使用 Docker（推薦）

```bash
cd docker
docker-compose up -d mongodb
```

#### 選項 B：本地安裝 MongoDB

請參考 [MongoDB 安裝文件](https://docs.mongodb.com/manual/installation/)

### 5. 啟動 API 服務

```bash
# 開發模式（自動重載）
cd api
python main.py

# 或使用 uvicorn
uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

API 將在 http://localhost:8000 啟動

### 6. 查看 API 文件

開啟瀏覽器訪問：
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 使用 Docker 部署

```bash
# 啟動所有服務（API + MongoDB）
cd docker
docker-compose up -d

# 查看日誌
docker-compose logs -f api

# 停止服務
docker-compose down
```

## API 端點

### 認證

- `POST /api/v1/auth/register` - 註冊
- `POST /api/v1/auth/login` - 登入
- `GET /api/v1/auth/me` - 取得當前使用者

### 座墊數據

- `POST /api/v1/seat-cushion/data` - 上傳座墊數據
- `GET /api/v1/seat-cushion/data/history` - 查詢歷史數據
- `GET /api/v1/seat-cushion/data/latest` - 取得最新數據
- `GET /api/v1/seat-cushion/statistics` - 統計資訊

### AI 分析

- `GET /api/v1/analysis/latest` - 取得最新分析結果
- `GET /api/v1/analysis/report` - 取得分析報告

## 開發指南

### 新增 API 端點

1. 在 `api/api/v1/endpoints/` 創建新檔案
2. 定義路由和處理函數
3. 在 `api/api/v1/api.py` 註冊路由

### 訓練 ML 模型

```bash
# 進入 ML 目錄
cd ml/training

# 啟動 Jupyter
jupyter notebook

# 開啟 notebooks 進行訓練
```

### 執行測試

```bash
pytest tests/
```

## 資料庫設計

### Collections

#### users
```javascript
{
  "_id": ObjectId,
  "email": String,
  "password_hash": String,
  "role": String,  // "patient", "doctor", "researcher"
  "profile": {
    "name": String,
    "hospital": String
  }
}
```

#### seat_cushion_data
```javascript
{
  "_id": ObjectId,
  "device_id": String,
  "user_id": ObjectId,
  "timestamp": ISODate,
  "raw_data": {
    "type": String,  // "left", "right"
    "forces": [[Number]]  // 31x8 矩陣
  },
  "features": {
    "total_force": Number,
    "center_of_pressure": {x: Number, y: Number}
  },
  "analysis": {
    "posture": String,
    "health_score": Number,
    "recommendations": [String]
  }
}
```

## AWS 部署

### 使用 AWS DocumentDB

```bash
# 在 .env 中設定 DocumentDB 連接字串
MONGODB_URL="mongodb://username:password@docdb-cluster.cluster-xxx.region.docdb.amazonaws.com:27017/?ssl=true&ssl_ca_certs=rds-combined-ca-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
```

### 使用 EC2/ECS 部署

1. 建置 Docker image
2. 推送到 ECR
3. 在 ECS 上部署

詳細步驟請參考 `doc/deployment/aws-deployment.md`

## 常見問題

### Q: MongoDB 連接失敗

**A**: 檢查：
1. MongoDB 是否已啟動：`docker-compose ps`
2. `.env` 中的連接字串是否正確
3. 防火牆設定

### Q: API 回傳 500 錯誤

**A**: 查看日誌：
```bash
docker-compose logs -f api
```

### Q: 如何重置資料庫

**A**:
```bash
# 進入 MongoDB container
docker exec -it medical_system_mongodb mongosh

# 刪除資料庫
use medical_system
db.dropDatabase()
```

## 授權

本專案為台北科技大學碩士論文專案。

## 聯絡方式

如有問題，請聯絡專案維護者。
