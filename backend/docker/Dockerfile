FROM python:3.11-slim

WORKDIR /app

# 安裝系統依賴
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 複製 requirements
COPY requirements.txt .
COPY requirements-ml.txt .

# 安裝 Python 套件
RUN pip install --no-cache-dir -r requirements.txt
# 如果需要 ML 功能，取消下面註解
# RUN pip install --no-cache-dir -r requirements-ml.txt

# 複製應用程式碼
COPY api/ ./api/
COPY ml/ ./ml/

# 暴露端口
EXPOSE 8000

# 啟動命令
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
