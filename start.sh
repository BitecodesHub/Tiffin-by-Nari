#!/bin/sh
set -e

echo "============================================"
echo "  Tiffins-by-Naari — Starting all services"
echo "============================================"

# ── 1. Start Python Recommendation Service (background) ──
echo "[1/2] Starting Python Recommendation Service on port 8000..."
cd /app/Python-Recommendation-Service
/app/venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000 --workers 2 &
PYTHON_PID=$!

# Wait for Python service to be ready
echo "      Waiting for Python service to be ready..."
for i in $(seq 1 30); do
  if wget -q --spider http://127.0.0.1:8000/docs 2>/dev/null; then
    echo "      Python service is ready!"
    break
  fi
  sleep 1
done

# ── 2. Start Node.js Backend + Frontend (foreground) ──
echo "[2/2] Starting Node.js Backend + Frontend on port 5000..."
cd /app/Backend
exec node src/production.js
