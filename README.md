# AUTO GO - Car Rental App

A modern car rental marketplace built with Flutter (Android) and Node.js backend.

## Features

- 🔐 **Authentication**: Firebase Authentication (Google, Email/Password, Phone)
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
- Firebase Authentication
- MVVM Architecture

### Backend
- Node.js + TypeScript
- Express.js
- PostgreSQL (with fallback to mock data for demo)
- Firebase Admin SDK

## 🚀 Quick Start

**See [SETUP.md](./SETUP.md) for setup instructions**

### Prerequisites
- Node.js (v18+)
- Flutter SDK
- Android Studio

### Quick Setup

1. **Clone and install:**
   ```bash
   git clone https://github.com/ahmadccplus/AutoGoFlutterApp.git
   cd AutoGoFlutterApp
   ```

2. **Backend:**
   ```bash
   cd backend
   npm install
   cp .env.example .env
   # Edit .env with your values
   npm run dev
   ```

3. **Flutter:**
   ```bash
   flutter pub get
   # Update lib/core/constants/app_constants.dart with your API URL
   ```

4. **Run:**
   - Open in Android Studio
   - Start emulator
   - Click Run (▶️)

## 📚 Documentation

- **[SETUP.md](./SETUP.md)** - Complete setup guide with step-by-step instructions
- **[QUICK_START.md](./QUICK_START.md)** - Quick reference guide

## ⚙️ Configuration

### Required Files (Not in Repository)

You need to create these files manually:

1. **`backend/.env`** - Copy from `backend/.env.example` and update values
   - Required: `PORT`, `JWT_SECRET`
   - Optional: Database and Firebase settings

2. **`android/app/google-services.json`** - Download from Firebase Console (if using Firebase)

### Environment Variables

See `backend/.env.example` for all available options. Minimum required:
- `PORT=3000`
- `JWT_SECRET=your_secret_key`

### API URL Configuration

Update `lib/core/constants/app_constants.dart`:
- **Android Emulator**: `http://10.0.2.2:3000/api`
- **Physical Device**: `http://YOUR_COMPUTER_IP:3000/api`
- **iOS Simulator**: `http://localhost:3000/api`

## 🧪 Testing

### Run Flutter Tests
```bash
flutter test
```

### Run Backend Tests
```bash
cd backend
npm test
```

## 📁 Project Structure

```
lib/
├── core/           # Constants, theme, network
├── data/           # Models, repositories
├── presentation/   # UI, providers, views
└── services/       # Auth, notifications, offline storage

backend/
├── src/
│   ├── controllers/  # API controllers
│   ├── models/       # Database models
│   ├── routes/       # API routes
│   └── services/     # Business logic
├── tests/            # Backend unit tests
└── migrations/       # Database migrations

test/
├── services/         # Flutter service tests
└── repositories/     # Flutter repository tests
```

## 🔧 Development

- **Hot Reload**: Press `r` in Flutter terminal
- **Hot Restart**: Press `R` (capital R)
- **Backend Auto-reload**: Uses `ts-node-dev` for automatic restarts

## 🐛 Troubleshooting

See [SETUP.md](./SETUP.md) for detailed troubleshooting guide.

Common issues:
- **Port already in use**: Change `PORT` in `backend/.env`
- **Can't connect to backend**: Check API URL in `app_constants.dart`
- **Firebase errors**: Verify `google-services.json` is in correct location
- **Database errors**: App works without database - check `.env` configuration

## 📝 Important Notes

- **Never commit `.env` files** - they contain sensitive information
- **Change `JWT_SECRET` in production** - use a strong random string
- **Firebase credentials are sensitive** - keep them secure
- **The app works in demo mode** without database or full Firebase setup

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

MIT

## 🙏 Support

For setup help, see [SETUP.md](./SETUP.md) or check the troubleshooting section.
