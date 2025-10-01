#!/bin/bash

# Get absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBLIC_DIR="$SCRIPT_DIR/public"

# Check if port 8000 is already in use
if lsof -i:8000 >/dev/null 2>&1; then
  echo "Error: Port 8000 is already in use"
  echo "Process using port 8000:"
  lsof -i:8000
  echo "Please stop the existing process or use a different port"
  exit 1
fi

# Initial build
cd "$SCRIPT_DIR"
ruby build.rb

# Start server in background with absolute path
ruby -run -e httpd "$PUBLIC_DIR" -p 8000 &
SERVER_PID=$!

echo "Server running at http://localhost:8000"
echo "Press Ctrl+C to stop"

# Build loop - stay in script directory
while true; do
  sleep 1
  ruby build.rb
done

# Cleanup on exit
trap "kill $SERVER_PID" EXIT
