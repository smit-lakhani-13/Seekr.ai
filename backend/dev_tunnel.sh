#!/usr/bin/env bash
# Expose local backend via ngrok for on-device testing without a Cloud Run deploy.
# Prereqs: ngrok installed (brew install ngrok) + auth token: ngrok config add-authtoken <token>
# Usage: bash dev_tunnel.sh
# Then pass the printed URL to Flutter: flutter run --dart-define=BACKEND_URL=<ngrok-https-url>
set -euo pipefail

PORT="${PORT:-8000}"
cd "$(dirname "$0")"

echo "=== Starting backend on port ${PORT} ==="
uv run uvicorn app.main:app --host 0.0.0.0 --port "${PORT}" &
SERVER_PID=$!
trap "echo 'Stopping server...'; kill ${SERVER_PID} 2>/dev/null || true" EXIT

echo "Waiting for server..."
sleep 2

echo "=== Opening ngrok tunnel ==="
echo "Copy the https:// URL and pass it to Flutter:"
echo "  flutter run --dart-define=BACKEND_URL=<ngrok-https-url>"
echo ""
ngrok http "${PORT}"
