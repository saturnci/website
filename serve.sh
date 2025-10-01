#!/bin/bash

# Configuration
PORT=9001

# Get absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBLIC_DIR="$SCRIPT_DIR/public"

# Check if port is already in use
if lsof -i:$PORT >/dev/null 2>&1; then
  echo "Error: Port $PORT is already in use"
  echo "Process using port $PORT:"
  lsof -i:$PORT
  echo "Please stop the existing process or use a different port"
  exit 1
fi

# Initial build
cd "$SCRIPT_DIR"
ruby build.rb

# Start server in background with absolute path
ruby -run -e httpd "$PUBLIC_DIR" -p $PORT &
SERVER_PID=$!

echo "Server running at http://localhost:$PORT"
echo "Press Ctrl+C to stop"

# Cleanup on exit - handle multiple signals
cleanup() {
  echo ""
  echo "Shutting down server..."
  if [ ! -z "$SERVER_PID" ]; then
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
  fi
  exit 0
}

trap cleanup EXIT INT TERM

# Build loop - stay in script directory
while true; do
  sleep 1
  ruby build.rb
done
