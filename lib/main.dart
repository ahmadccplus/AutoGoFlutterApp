import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/car_provider.dart';
import 'presentation/providers/booking_provider.dart';
import 'presentation/providers/payment_provider.dart';
import 'presentation/views/splash_screen.dart';
import 'presentation/views/home/home_screen.dart';
import 'presentation/views/auth/login_screen.dart';
import 'presentation/views/bookings/my_bookings_screen.dart';
import 'presentation/views/post_car/post_car_screen.dart';
import 'presentation/views/account/account_screen.dart';
import 'services/offline_storage_service.dart';
import 'services/notification_service.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize notifications
    await NotificationService.initialize();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('Firebase initialization failed: $e');
    print('Please configure Firebase by running: flutterfire configure');
    print('Or manually update lib/firebase_options.dart with your Firebase project settings');
    // App can still run without Firebase for basic testing
  }
  
  // Initialize Hive for local storage
  try {
    await OfflineStorageService.init();
  } catch (e) {
    print('Hive initialization failed: $e');
  }
  
  runApp(const AutoGoApp());
}

class AutoGoApp extends StatelessWidget {
  const AutoGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'AUTO GO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/bookings': (context) => const MyBookingsScreen(),
          '/post-car': (context) => const PostCarScreen(),
          '/account': (context) => const AccountScreen(),
        },
      ),
    );
  }
}

