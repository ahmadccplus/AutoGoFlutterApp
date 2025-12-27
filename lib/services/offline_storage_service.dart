import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/user_model.dart';
import '../data/models/car_model.dart';
import '../data/models/booking_model.dart';

class OfflineStorageService {
  static const String userBoxName = 'user_box';
  static const String carsBoxName = 'cars_box';
  static const String bookingsBoxName = 'bookings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters (in production, create proper Hive adapters)
    // For now, we'll use JSON serialization
  }

  // User Storage
  static Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox(userBoxName);
    await box.put('current_user', user.toJson());
  }

  static Future<UserModel?> getUser() async {
    final box = await Hive.openBox(userBoxName);
    final userJson = box.get('current_user');
    if (userJson != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(userJson));
    }
    return null;
  }

  static Future<void> clearUser() async {
    final box = await Hive.openBox(userBoxName);
    await box.clear();
  }

  // Cars Storage
  static Future<void> saveCars(List<CarModel> cars) async {
    final box = await Hive.openBox(carsBoxName);
    final carsJson = cars.map((car) => car.toJson()).toList();
    await box.put('cars', carsJson);
  }

  static Future<List<CarModel>> getCars() async {
    final box = await Hive.openBox(carsBoxName);
    final carsJson = box.get('cars') as List<dynamic>?;
    if (carsJson != null) {
      return carsJson
          .map((json) => CarModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return [];
  }

  static Future<void> clearCars() async {
    final box = await Hive.openBox(carsBoxName);
    await box.clear();
  }

  // Bookings Storage
  static Future<void> saveBookings(List<BookingModel> bookings) async {
    final box = await Hive.openBox(bookingsBoxName);
    final bookingsJson = bookings.map((booking) => booking.toJson()).toList();
    await box.put('bookings', bookingsJson);
  }

  static Future<List<BookingModel>> getBookings() async {
    final box = await Hive.openBox(bookingsBoxName);
    final bookingsJson = box.get('bookings') as List<dynamic>?;
    if (bookingsJson != null) {
      return bookingsJson
          .map((json) => BookingModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return [];
  }

  static Future<void> clearBookings() async {
    final box = await Hive.openBox(bookingsBoxName);
    await box.clear();
  }

  // Sync Status
  static Future<void> setLastSyncTime(DateTime time) async {
    final box = await Hive.openBox('sync_box');
    await box.put('last_sync', time.toIso8601String());
  }

  static Future<DateTime?> getLastSyncTime() async {
    final box = await Hive.openBox('sync_box');
    final timeString = box.get('last_sync') as String?;
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }
}








