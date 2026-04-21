#!/bin/sh
set -e

echo "============================================"
echo "  Tiffins-by-Naari — Starting all services"
echo "============================================"

# Render provides PORT env var — Node.js will use it automatically
echo "PORT=${PORT:-5000}"

# ── 1. Start Python Recommendation Service (background) ──
echo "[1/2] Starting Python Recommendation Service on port 8000..."
cd /app/Python-Recommendation-Service
/app/venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000 --workers 1 &
PYTHON_PID=$!
echo "      Python PID: $PYTHON_PID"

# Brief wait for Python to boot (don't block forever)
echo "      Waiting for Python service..."
TRIES=0
while [ $TRIES -lt 15 ]; do
  if wget -q -O /dev/null --timeout=2 http://127.0.0.1:8000/docs 2>/dev/null; then
    echo "      Python service is ready!"
    break
  fi
  TRIES=$((TRIES + 1))
  sleep 1
done

if [ $TRIES -eq 15 ]; then
  echo "      WARNING: Python service may not be ready yet, starting Node anyway..."
fi

# ── 2. Start Node.js Backend + Frontend (foreground) ──
echo "[2/2] Starting Node.js Backend on port ${PORT:-5000}..."
cd /app/Backend
exec node src/production.js
