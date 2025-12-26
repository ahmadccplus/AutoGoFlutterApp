#!/bin/bash

echo "🚗 AUTO GO - Setup Script"
echo "========================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Node.js and Flutter are installed"
echo ""

# Setup Backend
echo "📦 Setting up backend..."
cd backend

if [ ! -d "node_modules" ]; then
    echo "Installing backend dependencies..."
    npm install
else
    echo "Backend dependencies already installed"
fi

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cp .env.example .env 2>/dev/null || echo "Note: Please create .env file manually"
fi

cd ..
echo "✅ Backend setup complete"
echo ""

# Setup Flutter
echo "📱 Setting up Flutter app..."
if [ ! -d "lib" ]; then
    echo "❌ Flutter project structure not found"
    exit 1
fi

flutter pub get
echo "✅ Flutter setup complete"
echo ""

echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure PostgreSQL database"
echo "2. Update backend/.env with your database credentials"
echo "3. Run database migrations: psql -U postgres -d autogo_db -f backend/migrations/001_initial_schema.sql"
echo "4. Start backend: cd backend && npm run dev"
echo "5. Run Flutter app: flutter run"

