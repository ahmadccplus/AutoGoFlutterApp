# Complete Setup Guide for AUTO GO

This guide will walk you through setting up the AUTO GO app from scratch, even if you're not very technical.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: Install Required Software](#step-1-install-required-software)
3. [Step 2: Clone the Repository](#step-2-clone-the-repository)
4. [Step 3: Backend Setup](#step-3-backend-setup)
5. [Step 4: Database Setup (Optional)](#step-4-database-setup-optional)
6. [Step 5: Firebase Setup](#step-5-firebase-setup)
7. [Step 6: Flutter App Setup](#step-6-flutter-app-setup)
8. [Step 7: Running the App](#step-7-running-the-app)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, make sure you have:
- A computer (Windows, Mac, or Linux)
- Internet connection
- Basic understanding of using a terminal/command prompt

---

## Step 1: Install Required Software

### 1.1 Install Node.js
1. Go to [https://nodejs.org/](https://nodejs.org/)
2. Download the LTS (Long Term Support) version
3. Run the installer and follow the instructions
4. **Verify installation**: Open terminal/command prompt and type:
   ```bash
   node --version
   ```
   You should see a version number like `v18.x.x` or higher.

### 1.2 Install Flutter
1. Go to [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. Follow the installation guide for your operating system
3. **Verify installation**: Open terminal and type:
   ```bash
   flutter --version
   ```
   You should see Flutter version information.

### 1.3 Install Android Studio
1. Go to [https://developer.android.com/studio](https://developer.android.com/studio)
2. Download and install Android Studio
3. During installation, make sure to install:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (AVD)
4. Open Android Studio and complete the setup wizard

### 1.4 Install PostgreSQL (Optional - for database)
**Note**: The app works without a database in demo mode, but for full functionality, you'll need PostgreSQL.

1. Go to [https://www.postgresql.org/download/](https://www.postgresql.org/download/)
2. Download and install PostgreSQL for your operating system
3. Remember the password you set for the `postgres` user (you'll need it later)

---

## Step 2: Clone the Repository

1. Open terminal/command prompt
2. Navigate to where you want to store the project (e.g., Desktop):
   ```bash
   cd ~/Desktop
   ```
3. Clone the repository:
   ```bash
   git clone https://github.com/ahmadccplus/AutoGoFlutterApp.git
   ```
4. Navigate into the project:
   ```bash
   cd AutoGoFlutterApp
   ```

---

## Step 3: Backend Setup

### 3.1 Install Backend Dependencies

1. Navigate to the backend folder:
   ```bash
   cd backend
   ```

2. Install Node.js packages:
   ```bash
   npm install
   ```
   This may take a few minutes. Wait for it to complete.

### 3.2 Create Backend Environment File

**IMPORTANT**: The `.env` file is not included in the repository for security reasons. You must create it manually.

1. In the `backend` folder, create a new file named `.env` (note the dot at the beginning)
2. Open the `.env` file in a text editor
3. Copy and paste the following content:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration (Optional - app works without database)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=autogo_db
DB_USER=postgres
DB_PASSWORD=your_postgres_password_here

# JWT Secret (Change this to a random string in production)
JWT_SECRET=autogo_jwt_secret_key_for_development_only_change_in_production
JWT_EXPIRES_IN=7d

# Firebase Configuration (Optional - see Firebase Setup section)
# Option 1: Service Account Key (JSON as string)
# FIREBASE_SERVICE_ACCOUNT_KEY={"type":"service_account","project_id":"your-project-id",...}

# Option 2: Path to service account file
# GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json

# Firebase Project ID (for notifications)
FIREBASE_PROJECT_ID=your-firebase-project-id

# Stripe Payment (Optional - for payment features)
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
```

4. **Replace the values**:
   - `DB_PASSWORD`: Your PostgreSQL password (if using database)
   - `FIREBASE_PROJECT_ID`: Your Firebase project ID (see Firebase Setup)
   - `JWT_SECRET`: Change to a random string for production (you can use an online generator)

5. Save the file

**Note**: For development/testing, you can leave most values as-is. The app will work in demo mode without a database or Firebase.

---

## Step 4: Database Setup (Optional)

The app works in demo mode without a database. Skip this step if you want to test quickly.

### 4.1 Create Database

1. Open PostgreSQL (pgAdmin or command line)
2. Create a new database named `autogo_db`:
   ```sql
   CREATE DATABASE autogo_db;
   ```

### 4.2 Run Database Migrations

1. In terminal, navigate to the backend folder:
   ```bash
   cd backend
   ```

2. Run the migration:
   ```bash
   psql -U postgres -d autogo_db -f migrations/001_initial_schema.sql
   ```
   
   If you set a password, you'll be prompted for it.

   **Alternative** (if you have a password):
   ```bash
   PGPASSWORD=your_password psql -U postgres -d autogo_db -f migrations/001_initial_schema.sql
   ```

3. Verify the tables were created:
   ```bash
   psql -U postgres -d autogo_db -c "\dt"
   ```
   You should see tables: `users`, `cars`, `bookings`, `kyc_documents`

---

## Step 5: Firebase Setup

Firebase is used for authentication. The app can work without Firebase in development mode, but authentication features require it.

### 5.1 Create Firebase Project

1. Go to [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `AutoGo` (or any name you prefer)
4. Follow the setup wizard (you can disable Google Analytics if you want)
5. Click "Create project"

### 5.2 Enable Authentication

1. In Firebase Console, go to **Authentication** → **Get started**
2. Click **Sign-in method** tab
3. Enable the following providers:
   - **Email/Password**: Click, enable, save
   - **Google**: Click, enable, enter support email, save
   - **Phone**: Click, enable, save

### 5.3 Add Android App to Firebase

1. In Firebase Console, click the gear icon ⚙️ → **Project settings**
2. Scroll down to "Your apps" section
3. Click the Android icon (or "Add app" → Android)
4. Enter package name: `com.autogo.autogo`
5. Register app
6. Download `google-services.json`
7. **IMPORTANT**: Copy `google-services.json` to:
   ```
   android/app/google-services.json
   ```
   (Replace the existing file if it's there)

### 5.4 Get Firebase Configuration

1. In Firebase Console → Project settings → General tab
2. Scroll to "Your apps" → find your Android app
3. Copy the following values:
   - `apiKey`
   - `appId`
   - `messagingSenderId`
   - `projectId`

4. Update `lib/firebase_options.dart` with these values (see Flutter Setup section)

### 5.5 Get Service Account Key (For Backend - Optional)

**Only needed if you want full Firebase token verification on the backend.**

1. In Firebase Console → Project settings → Service accounts
2. Click "Generate new private key"
3. Download the JSON file
4. You have two options:

   **Option A**: Add to `.env` as a string
   - Open the JSON file, copy all content
   - In `backend/.env`, add:
     ```env
     FIREBASE_SERVICE_ACCOUNT_KEY={"type":"service_account","project_id":"...",...}
     ```
   - Paste the entire JSON as one line

   **Option B**: Use file path
   - Save the JSON file somewhere safe (e.g., `backend/firebase-service-account.json`)
   - In `backend/.env`, add:
     ```env
     GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/firebase-service-account.json
     ```

**Note**: For development, you can skip this step. The app will work with token decoding (less secure but fine for testing).

---

## Step 6: Flutter App Setup

### 6.1 Install Flutter Dependencies

1. In terminal, navigate to the project root:
   ```bash
   cd AutoGoFlutterApp
   ```

2. Install Flutter packages:
   ```bash
   flutter pub get
   ```
   Wait for it to complete.

### 6.2 Configure Firebase Options

1. Open `lib/firebase_options.dart` in a text editor
2. Find the Android configuration section
3. Replace the placeholder values with your Firebase project values:
   ```dart
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'YOUR_API_KEY',  // From Firebase Console
     appId: 'YOUR_APP_ID',    // From Firebase Console
     messagingSenderId: 'YOUR_SENDER_ID',  // From Firebase Console
     projectId: 'YOUR_PROJECT_ID',  // From Firebase Console
     // ... other values
   );
   ```
4. Do the same for iOS, Web, and macOS if you plan to use those platforms

### 6.3 Configure API URL

1. Open `lib/core/constants/app_constants.dart`
2. Find the `baseUrl` line
3. Update based on how you'll run the app:

   **For Android Emulator:**
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000/api';
   ```

   **For Physical Device:**
   ```dart
   static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
   ```
   Replace `YOUR_COMPUTER_IP` with your computer's IP address:
   - **Windows**: Open command prompt, type `ipconfig`, look for "IPv4 Address"
   - **Mac/Linux**: Open terminal, type `ifconfig` or `ip addr`, look for your network interface IP

   **For iOS Simulator (Mac only):**
   ```dart
   static const String baseUrl = 'http://localhost:3000/api';
   ```

---

## Step 7: Running the App

### 7.1 Start the Backend Server

1. Open a terminal window
2. Navigate to the backend folder:
   ```bash
   cd AutoGoFlutterApp/backend
   ```

3. Start the server:
   ```bash
   npm run dev
   ```

4. You should see:
   ```
   Server is running on port 3000
   ```

5. **Keep this terminal open** - the server needs to keep running

### 7.2 Test Backend (Optional)

Open a web browser and go to:
```
http://localhost:3000/health
```

You should see:
```json
{"status":"ok","timestamp":"..."}
```

### 7.3 Run Flutter App

1. Open Android Studio
2. Click "Open" and select the `AutoGoFlutterApp` folder
3. Wait for Android Studio to index the project
4. Create/Start an Android Emulator:
   - Click "Device Manager" (phone icon in toolbar)
   - Click "Create Device" if you don't have one
   - Select a device (e.g., Pixel 5)
   - Download a system image if needed
   - Click "Finish"
5. Click the green "Run" button (▶️) or press `Shift+F10`
6. Wait for the app to build and launch

---

## Troubleshooting

### Backend Issues

**Problem**: `npm install` fails
- **Solution**: Make sure Node.js is installed correctly. Try `node --version` to verify.

**Problem**: `Port 3000 already in use`
- **Solution**: Change `PORT=3001` in `backend/.env`, or stop the process using port 3000.

**Problem**: Database connection error
- **Solution**: 
  - Make sure PostgreSQL is running
  - Check your database credentials in `backend/.env`
  - The app works without a database in demo mode - you can skip database setup

**Problem**: `Cannot find module` errors
- **Solution**: Run `npm install` again in the `backend` folder

### Flutter Issues

**Problem**: `flutter pub get` fails
- **Solution**: 
  - Make sure Flutter is installed: `flutter doctor`
  - Run `flutter clean` then `flutter pub get`

**Problem**: Build errors
- **Solution**: 
  - Run `flutter clean`
  - Run `flutter pub get`
  - In Android Studio: File → Invalidate Caches → Restart

**Problem**: App can't connect to backend
- **Solution**: 
  - Make sure backend is running (check terminal)
  - Check `app_constants.dart` - make sure the URL is correct
  - For physical device: Make sure your phone and computer are on the same WiFi network
  - Check firewall settings - port 3000 might be blocked

**Problem**: Firebase errors
- **Solution**: 
  - Make sure `google-services.json` is in `android/app/` folder
  - Verify Firebase configuration in `firebase_options.dart`
  - Check Firebase Console - make sure authentication methods are enabled

### General Issues

**Problem**: Can't find `.env` file
- **Solution**: 
  - Make sure the file is named exactly `.env` (with the dot at the beginning)
  - On Windows, you might need to enable "Show hidden files"
  - The file should be in the `backend` folder

**Problem**: Authentication not working
- **Solution**: 
  - Check Firebase Console - make sure Email/Password and Google sign-in are enabled
  - Verify `firebase_options.dart` has correct values
  - Check backend logs for errors

---

## Quick Test Without Full Setup

If you want to test the app quickly without setting up everything:

1. **Skip Database**: The app works in demo mode without PostgreSQL
2. **Skip Firebase Backend Verification**: The backend will decode tokens without verification
3. **Minimal Firebase Setup**: Just add the Android app to Firebase and download `google-services.json`
4. **Use Default Values**: Most `.env` values can stay as default for development

The app will work with limited functionality, but you can test the UI and basic features.

---

## Next Steps

Once everything is set up:

1. **Test Authentication**: Try signing up with email/password
2. **Test Google Sign-In**: Try signing in with Google
3. **Browse Cars**: The app will use mock data if database isn't set up
4. **Create Bookings**: Test the booking flow

---

## Getting Help

If you encounter issues:

1. Check the error messages in the terminal/console
2. Review the Troubleshooting section above
3. Check that all environment variables are set correctly
4. Verify all software is installed and up to date

---

## Important Notes

- **Never commit `.env` files** - they contain sensitive information
- **Change JWT_SECRET in production** - use a strong random string
- **Firebase credentials are sensitive** - keep them secure
- **Database password** - use a strong password in production

---

## Summary Checklist

- [ ] Node.js installed
- [ ] Flutter installed
- [ ] Android Studio installed
- [ ] Repository cloned
- [ ] Backend dependencies installed (`npm install`)
- [ ] Backend `.env` file created with correct values
- [ ] Database created (optional)
- [ ] Firebase project created
- [ ] Firebase authentication enabled
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] `firebase_options.dart` updated with Firebase values
- [ ] `app_constants.dart` updated with correct API URL
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] Backend server running (`npm run dev`)
- [ ] App running on emulator/device

Once all items are checked, you're ready to use the app! 🚀

