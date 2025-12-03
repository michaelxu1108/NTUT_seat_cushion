# 快速啟動指南

## 方法 1：使用 Docker（最簡單）

```bash
# 1. 進入 docker 目錄
cd backend/docker

# 2. 啟動所有服務
docker-compose up -d

# 3. 查看 API 是否啟動
curl http://localhost:8000/health

# 4. 開啟 API 文件
open http://localhost:8000/docs
```

## 方法 2：本地開發

### 步驟 1：安裝 MongoDB

```bash
# macOS (使用 Homebrew)
brew install mongodb-community
brew services start mongodb-community

# 或使用 Docker 只啟動 MongoDB
cd backend/docker
docker-compose up -d mongodb
```

### 步驟 2：設定 Python 環境

```bash
# 進入後端目錄
cd backend

# 創建虛擬環境
python3 -m venv venv

# 啟動虛擬環境
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate  # Windows

# 安裝依賴
pip install -r requirements.txt
```

### 步驟 3：設定環境變數

```bash
# 複製範例檔案
cp .env.example .env

# 編輯 .env（如果使用預設值，可以不改）
# vim .env
```

### 步驟 4：初始化資料庫

```bash
# 創建索引
python scripts/init_db.py

# （可選）創建測試數據
python scripts/seed_data.py
```

### 步驟 5：啟動 API

```bash
# 進入 api 目錄
cd api

# 啟動 API（開發模式）
python main.py

# 或使用 uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 步驟 6：測試 API

```bash
# 健康檢查
curl http://localhost:8000/health

# 查看 API 文件
open http://localhost:8000/docs
```

## 測試帳號

如果執行了 `seed_data.py`，可以使用以下測試帳號：

- **醫生帳號**
  - Email: `doctor@example.com`
  - Password: `password123`

- **病患帳號**
  - Email: `patient@example.com`
  - Password: `password123`

## 常用指令

```bash
# 停止 Docker 服務
docker-compose down

# 查看 API 日誌
docker-compose logs -f api

# 查看 MongoDB 日誌
docker-compose logs -f mongodb

# 進入 MongoDB shell
docker exec -it medical_system_mongodb mongosh

# 重新啟動 API
docker-compose restart api
```

## 下一步

1. 查看完整文件：`README.md`
2. 查看 API 文件：http://localhost:8000/docs
3. 開始實作業務邏輯：修改 `api/api/v1/endpoints/` 中的檔案
4. 訓練 ML 模型：參考 `ml/training/README.md`

## 故障排除

### 問題：Port 8000 已被占用

```bash
# 查看是什麼在使用 port 8000
lsof -i :8000

# 停止該 process 或在 docker-compose.yml 中改用其他 port
```

### 問題：MongoDB 連接失敗

```bash
# 確認 MongoDB 是否在運行
docker ps | grep mongodb

# 重啟 MongoDB
docker-compose restart mongodb
```

### 問題：Module not found

```bash
# 確認虛擬環境已啟動
which python

# 重新安裝依賴
pip install -r requirements.txt
```
