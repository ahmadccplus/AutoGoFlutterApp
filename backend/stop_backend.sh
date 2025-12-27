#!/bin/bash

echo "🛑 Stopping AUTO GO Backend Server..."

# Kill processes on port 3000
lsof -ti :3000 | xargs kill -9 2>/dev/null

# Kill ts-node-dev processes
pkill -f "ts-node-dev" 2>/dev/null

# Kill npm run dev processes
pkill -f "npm run dev" 2>/dev/null

sleep 1

if lsof -ti :3000 > /dev/null 2>&1; then
    echo "⚠️  Port 3000 is still in use. Force killing..."
    lsof -ti :3000 | xargs kill -9 2>/dev/null
    sleep 1
fi

if lsof -ti :3000 > /dev/null 2>&1; then
    echo "❌ Failed to free port 3000"
    exit 1
else
    echo "✅ Backend stopped. Port 3000 is now free."
fi






