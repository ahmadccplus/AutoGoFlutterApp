import 'dart:io';
import 'offline_storage_service.dart';
import '../data/models/user_model.dart';
import '../data/models/car_model.dart';
import '../data/models/booking_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/car_repository.dart';
import '../data/repositories/booking_repository.dart';

class SyncService {
  final AuthRepository _authRepository = AuthRepository();
  final CarRepository _carRepository = CarRepository();
  final BookingRepository _bookingRepository = BookingRepository();

  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncUser() async {
    if (!await isOnline()) return;

    try {
      final user = await _authRepository.getCurrentUser();
      await OfflineStorageService.saveUser(user);
    } catch (e) {
      print('Error syncing user: $e');
    }
  }

  Future<void> syncCars() async {
    if (!await isOnline()) return;

    try {
      final cars = await _carRepository.getAvailableCars();
      await OfflineStorageService.saveCars(cars);
    } catch (e) {
      print('Error syncing cars: $e');
    }
  }

  Future<void> syncBookings() async {
    if (!await isOnline()) return;

    try {
      final bookings = await _bookingRepository.getMyBookings();
      await OfflineStorageService.saveBookings(bookings);
    } catch (e) {
      print('Error syncing bookings: $e');
    }
  }

  Future<void> syncAll() async {
    if (!await isOnline()) {
      print('Device is offline, skipping sync');
      return;
    }

    try {
      await Future.wait([
        syncUser(),
        syncCars(),
        syncBookings(),
      ]);
      await OfflineStorageService.setLastSyncTime(DateTime.now());
      print('Sync completed successfully');
    } catch (e) {
      print('Error during sync: $e');
    }
  }

  // Load cached data when offline
  Future<UserModel?> loadCachedUser() async {
    return await OfflineStorageService.getUser();
  }

  Future<List<CarModel>> loadCachedCars() async {
    return await OfflineStorageService.getCars();
  }

  Future<List<BookingModel>> loadCachedBookings() async {
    return await OfflineStorageService.getBookings();
  }
}



