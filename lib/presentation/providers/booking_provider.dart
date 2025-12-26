import 'package:flutter/foundation.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository = BookingRepository();

  List<BookingModel> _bookings = [];
  BookingModel? _currentBooking;
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> createBooking({
    required int carId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
    required double securityDeposit,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentBooking = await _repository.createBooking(
        carId: carId,
        startDate: startDate,
        endDate: endDate,
        totalPrice: totalPrice,
        securityDeposit: securityDeposit,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getMyBookings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _bookings = await _repository.getMyBookings();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBookings() async {
    await getMyBookings();
  }

  Future<void> signContract(int bookingId, String signatureUrl) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentBooking = await _repository.signContract(bookingId, signatureUrl);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelBooking(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.cancelBooking(id);
      _bookings = _bookings.where((b) => b.id != id).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}



