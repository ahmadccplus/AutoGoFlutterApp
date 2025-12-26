# Running AutoGo from Android Studio

Yes! You can run the entire development flow from Android Studio. Here's how:

## Option 1: Using Android Studio Terminal (Recommended)

1. **Open Android Studio**
   - Open the project: `/Users/ahmedelsisi/Desktop/AutoGoFlutterApp`

2. **Start Backend Server**
   - Open the terminal in Android Studio (View → Tool Windows → Terminal)
   - Run: `./start_dev.sh`
   - This will start the backend server automatically

3. **Run Flutter App**
   - Select your Android emulator/device from the device dropdown
   - Click the **Run** button (▶️) or press **Shift+F10**
   - Or use terminal: `flutter run`

## Option 2: Using Run Configurations

### Create Backend Run Configuration

1. **Go to Run → Edit Configurations...**
2. **Click + → Shell Script**
3. **Configure:**
   - Name: `Start Backend`
   - Shell script path: `$PROJECT_DIR$/start_backend.sh`
   - Working directory: `$PROJECT_DIR$`
4. **Click OK**

### Create Flutter Run Configuration

1. **Go to Run → Edit Configurations...**
2. **Click + → Flutter**
3. **Configure:**
   - Name: `Run AutoGo`
   - Dart entrypoint: `lib/main.dart`
   - Additional run args: (leave empty)
4. **Click OK**

### Running Both

1. **Start Backend:**
   - Select "Start Backend" from run configurations
   - Click Run (▶️)

2. **Run Flutter App:**
   - Select "Run AutoGo" from run configurations
   - Click Run (▶️)

## Option 3: Quick Terminal Commands

In Android Studio terminal:

```bash
# Start backend
cd backend && npm run dev &

# Run Flutter app
flutter run
```

## Viewing Backend Logs

In Android Studio terminal:
```bash
tail -f /tmp/autogo_backend.log
```

## Stopping Backend

In Android Studio terminal:
```bash
./stop_backend.sh
```

## Tips

- **Hot Reload**: Press `r` in Flutter terminal for hot reload
- **Hot Restart**: Press `R` (capital R) for hot restart
- **Backend Logs**: Check `/tmp/autogo_backend.log` for backend output
- **Backend Health**: Test with `curl http://localhost:3000/health`

## Troubleshooting

**Backend won't start:**
- Check if port 3000 is already in use: `lsof -i :3000`
- Kill existing process: `./stop_backend.sh`

**Flutter app can't connect:**
- Verify backend is running: `curl http://localhost:3000/health`
- Check `lib/core/constants/app_constants.dart` for correct API URL

**Port conflicts:**
- Backend uses port 3000
- Make sure nothing else is using it

## Recommended Workflow

1. **Start Android Studio**
2. **Open terminal** (View → Tool Windows → Terminal)
3. **Run**: `./start_dev.sh`
4. **Select Android emulator/device**
5. **Click Run button** (▶️) to start Flutter app
6. **Develop with hot reload** (press `r` after code changes)

That's it! Everything runs from Android Studio! 🚀

