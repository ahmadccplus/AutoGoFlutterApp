# Setup Guide - AUTO GO

This guide will help you set up the AUTO GO project after cloning it from GitHub.

## Quick Setup

### 1. Backend Setup

1. Navigate to the backend folder:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. **Create `.env` file** (this file is not in the repository):
   - Copy `backend/.env.example` to `backend/.env`
   - Open `backend/.env` and update the values:
     ```env
     PORT=3000
     NODE_ENV=development
     
     # Database (optional - app works without it)
     DB_HOST=localhost
     DB_PORT=5432
     DB_NAME=autogo_db
     DB_USER=postgres
     DB_PASSWORD=your_password_here
     
     # JWT Secret (change this!)
     JWT_SECRET=your_random_secret_key_here
     JWT_EXPIRES_IN=7d
     
     # Firebase (optional for development)
     FIREBASE_PROJECT_ID=your-project-id
     ```

4. Start the backend:
   ```bash
   npm run dev
   ```

### 2. Flutter App Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. **Configure API URL** in `lib/core/constants/app_constants.dart`:
   - For Android Emulator: `http://10.0.2.2:3000/api`
   - For Physical Device: `http://YOUR_COMPUTER_IP:3000/api`

3. **Firebase Configuration** (if using Firebase):
   - Make sure `android/app/google-services.json` exists
   - Update `lib/firebase_options.dart` with your Firebase project values

### 3. Run the App

1. Start the backend server (keep it running):
   ```bash
   cd backend
   npm run dev
   ```

2. In Android Studio:
   - Open the project
   - Start an Android emulator
   - Click Run (▶️)

## Files You Need to Create

These files are **not** in the repository and must be created manually:

### `backend/.env`
- Copy from `backend/.env.example`
- Update with your actual values
- **Required**: `PORT`, `JWT_SECRET`
- **Optional**: Database and Firebase settings

### `android/app/google-services.json` (if using Firebase)
- Download from Firebase Console
- Place in `android/app/google-services.json`

## Environment Variables Reference

### Required
- `PORT` - Backend server port (default: 3000)
- `JWT_SECRET` - Secret key for JWT tokens (change from default!)

### Optional (app works without these)
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` - Database connection
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `FIREBASE_SERVICE_ACCOUNT_KEY` - Firebase service account JSON (as string)
- `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` - Stripe payment keys

## Testing

The app works in **demo mode** without a database or full Firebase setup. You can test it immediately after:
1. Creating `backend/.env` with basic values
2. Running `npm install` in backend
3. Running `flutter pub get`
4. Starting the backend and Flutter app

## Troubleshooting

**Backend won't start:**
- Check that `backend/.env` exists
- Verify `PORT` is not already in use

**App can't connect to backend:**
- Make sure backend is running
- Check API URL in `lib/core/constants/app_constants.dart`
- For physical device: ensure phone and computer are on same WiFi

**Firebase errors:**
- Verify `google-services.json` is in `android/app/`
- Check `firebase_options.dart` has correct values
