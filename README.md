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

**For detailed setup instructions, see [SETUP.md](./SETUP.md)**

### Prerequisites
- Node.js (v18+)
- Flutter SDK
- Android Studio with Android emulator
- PostgreSQL (optional - app works without it)

### Quick Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ahmadccplus/AutoGoFlutterApp.git
   cd AutoGoFlutterApp
   ```

2. **Setup Backend:**
   ```bash
   cd backend
   npm install
   # Create .env file (see SETUP.md for details)
   cp .env.example .env
   # Edit .env with your configuration
   npm run dev
   ```

3. **Setup Flutter App:**
   ```bash
   cd ..
   flutter pub get
   # Configure Firebase (see SETUP.md)
   # Update lib/core/constants/app_constants.dart with your API URL
   ```

4. **Run the app:**
   - Open project in Android Studio
   - Start Android emulator
   - Click Run (▶️)

## 📚 Documentation

- **[SETUP.md](./SETUP.md)** - Complete setup guide with step-by-step instructions
- **[QUICK_START.md](./QUICK_START.md)** - Quick reference guide

## ⚙️ Configuration

### Environment Variables

The backend requires a `.env` file in the `backend/` folder. See `backend/.env.example` for a template.

**Required for basic functionality:**
- `PORT` - Server port (default: 3000)
- `JWT_SECRET` - Secret key for JWT tokens

**Optional (app works without these in demo mode):**
- Database configuration (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`)
- Firebase configuration (`FIREBASE_SERVICE_ACCOUNT_KEY` or `GOOGLE_APPLICATION_CREDENTIALS`)
- Stripe configuration (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`)

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password, Google, Phone)
3. Add Android app to Firebase
4. Download `google-services.json` and place it in `android/app/`
5. Update `lib/firebase_options.dart` with your Firebase configuration

See [SETUP.md](./SETUP.md) for detailed Firebase setup instructions.

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
