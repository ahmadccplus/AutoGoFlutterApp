#!/bin/bash

echo "🚀 Starting AUTO GO Backend Server..."
echo ""

cd "$(dirname "$0")/backend"

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from template..."
    cat > .env << EOF
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=autogo_db
DB_USER=postgres
DB_PASSWORD=postgres
JWT_SECRET=autogo_jwt_secret_key_for_development_only_change_in_production
JWT_EXPIRES_IN=7d
CORS_ORIGIN=http://localhost:3000
EOF
    echo "✅ Created .env file. Please update database credentials if needed."
    echo ""
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo ""
fi

echo "🚀 Starting server on http://localhost:3000"
echo "Press Ctrl+C to stop"
echo ""

npm run dev
