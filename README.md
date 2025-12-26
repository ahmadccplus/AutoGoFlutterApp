# AUTO GO - Car Rental App

A modern car rental marketplace built with Flutter (Android) and Node.js backend.

## Features

- 🔐 **Authentication**: Phone OTP, Google, Facebook login
- 🚗 **Car Listings**: Browse, search, and filter available cars
- 📅 **Booking System**: Book cars with date selection and digital contracts
- 💳 **Payment**: Pay on pickup option
- 👤 **User Profiles**: Manage account and view booking history
- 🚙 **Host Features**: Post your car for rent
- 📱 **Modern UI**: Clean, intuitive interface

## Tech Stack

### Frontend
- Flutter (Android)
- Provider (State Management)
- MVVM Architecture

### Backend
- Node.js + TypeScript
- Express.js
- PostgreSQL (with fallback to mock data for demo)

## Quick Start

### Prerequisites
- Flutter SDK
- Node.js (v18+)
- Android Studio with Android emulator

### Setup

1. **Start Backend:**
   ```bash
   ./start_dev.sh
   ```
   Or manually:
   ```bash
   cd backend
   npm install
   npm run dev
   ```

2. **Run Flutter App:**
   - Open project in Android Studio
   - Select Android emulator/device
   - Click Run (▶️) or press `Shift+F10`

### Development

- **Hot Reload**: Press `r` in Flutter terminal
- **Hot Restart**: Press `R` (capital R)
- **Backend Logs**: `tail -f /tmp/autogo_backend.log`
- **Stop Backend**: `./stop_backend.sh`

## Project Structure

```
lib/
├── core/           # Constants, theme, network
├── data/           # Models, repositories
├── presentation/    # UI, providers, views
└── services/       # Auth, notifications, offline storage

backend/
├── src/
│   ├── controllers/  # API controllers
│   ├── models/       # Database models
│   ├── routes/       # API routes
│   └── services/     # Business logic
└── migrations/       # Database migrations
```

## API Configuration

Update `lib/core/constants/app_constants.dart`:
- Android Emulator: `http://10.0.2.2:3000/api`
- Physical Device: `http://YOUR_COMPUTER_IP:3000/api`

## Demo Mode

The app works in demo mode without a database connection. Mock data is automatically used when the database is unavailable.

## Navigation

- **Search** (0): Home screen with car listings
- **Bookings** (1): Current bookings and history
- **Post Car** (2): Post your car for rent
- **Account** (3): Profile and settings

## License

MIT
