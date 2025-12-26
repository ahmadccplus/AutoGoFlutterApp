class AppConstants {
  // API Configuration
  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator, or your computer's IP for physical device
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api'; // Physical device
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // User Roles
  static const String roleRenter = 'renter';
  static const String roleHost = 'host';

  // Booking Status
  static const String bookingStatusPending = 'pending';
  static const String bookingStatusActive = 'active';
  static const String bookingStatusCompleted = 'completed';
  static const String bookingStatusCancelled = 'cancelled';


  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';

  // Pagination
  static const int defaultPageSize = 20;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
}



