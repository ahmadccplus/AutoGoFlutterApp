#!/bin/bash

# AutoGo Development Startup Script
# This script starts both the backend and provides instructions for running Flutter

echo "=========================================="
echo "  AUTO GO - Development Environment"
echo "=========================================="
echo ""

# Check if backend is already running
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Backend is already running on port 3000"
    read -p "Do you want to restart it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Stopping existing backend..."
        lsof -ti:3000 | xargs kill -9 2>/dev/null
        sleep 2
    else
        echo "Keeping existing backend running"
        BACKEND_RUNNING=true
    fi
else
    BACKEND_RUNNING=false
fi

# Start backend if not running
if [ "$BACKEND_RUNNING" = false ]; then
    echo ""
    echo "🚀 Starting backend server..."
    cd backend
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing backend dependencies..."
        npm install
    fi
    
    # Start backend in background
    npm run dev > /tmp/autogo_backend.log 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > /tmp/autogo_backend_pid.txt
    echo "✅ Backend started (PID: $BACKEND_PID)"
    echo "   Logs: /tmp/autogo_backend.log"
    
    # Wait a bit for backend to start
    sleep 3
    
    # Check if backend is responding
    if curl -s http://localhost:3000/health > /dev/null 2>&1; then
        echo "✅ Backend is responding"
    else
        echo "⚠️  Backend may still be starting up..."
    fi
    
    cd ..
fi

echo ""
echo "=========================================="
echo "  Backend Status: ✅ Running on port 3000"
echo "=========================================="
echo ""
echo "📱 To run Flutter app:"
echo "   1. Open Android Studio"
echo "   2. Open this project: $(pwd)"
echo "   3. Select your Android emulator/device"
echo "   4. Click the 'Run' button (▶️) or press Shift+F10"
echo ""
echo "   OR use terminal:"
echo "   flutter run"
echo ""
echo "🔧 Useful commands:"
echo "   - View backend logs: tail -f /tmp/autogo_backend.log"
echo "   - Stop backend: ./stop_backend.sh"
echo "   - Check backend: curl http://localhost:3000/health"
echo ""
echo "=========================================="

