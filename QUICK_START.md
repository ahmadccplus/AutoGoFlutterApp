# Quick Start Guide - Test Run AUTO GO

## Prerequisites Check

Before running, ensure you have:
- ✅ Node.js (v18+) installed
- ✅ Flutter SDK installed
- ✅ PostgreSQL installed and running
- ✅ Android device/emulator (for Flutter)

## Step 1: Setup Backend

```bash
cd backend
npm install
```

## Step 2: Configure Database

1. Create PostgreSQL database:
```bash
createdb autogo_db
```

2. Run migrations:
```bash
psql -U postgres -d autogo_db -f migrations/001_initial_schema.sql
```

Or if you need to set a password:
```bash
PGPASSWORD=postgres psql -U postgres -d autogo_db -f migrations/001_initial_schema.sql
```

3. Update `.env` file in `backend/` directory with your database credentials:
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=autogo_db
DB_USER=postgres
DB_PASSWORD=your_password
```

## Step 3: Start Backend Server

```bash
cd backend
npm run dev
```

The backend should start on `http://localhost:3000`

You can test it by visiting: `http://localhost:3000/health`

## Step 4: Setup Flutter App

```bash
# From project root
flutter pub get
```

## Step 5: Configure Flutter App

1. Update API URL in `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api'; // For Android emulator
// OR
static const String baseUrl = 'http://localhost:3000/api'; // For physical device (use your computer's IP)
```

2. For Android emulator, use `10.0.2.2` instead of `localhost`

## Step 6: Run Flutter App

```bash
flutter run
```

Or if you have multiple devices:
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

## Testing the App

### Test Login Flow:
1. Open the app
2. Enter a phone number (e.g., +1234567890)
3. Click "Continue with Phone"
4. Enter OTP: **123456** (test OTP)
5. Complete KYC verification (optional for testing)

### Test Features:
- Browse cars (if any are in database)
- Search and filter cars
- View car details
- Create a booking
- Sign contract
- Make payment (Stripe test mode)

## Troubleshooting

### Backend Issues:
- **Port already in use**: Change PORT in `.env`
- **Database connection error**: Check PostgreSQL is running and credentials are correct
- **Module not found**: Run `npm install` again

### Flutter Issues:
- **Build errors**: Run `flutter clean && flutter pub get`
- **API connection error**: Check backend is running and URL is correct
- **Firebase errors**: Firebase is optional for basic testing - you can comment out Firebase initialization in `main.dart` for now

### Database Issues:
- **Migration errors**: Make sure database exists and user has permissions
- **Table already exists**: Drop and recreate database or modify migration

## Quick Test Without Database

For a quick test without setting up PostgreSQL, you can:
1. Comment out database queries in backend
2. Use mock data
3. Test UI flows only

## Next Steps After Testing

1. Set up Firebase for notifications
2. Configure Google Maps API key
3. Set up Stripe test account
4. Add real OTP service (Twilio)
5. Deploy backend to cloud

