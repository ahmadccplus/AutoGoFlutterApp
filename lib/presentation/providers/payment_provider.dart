import 'package:flutter/foundation.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository = PaymentRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _clientSecret;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get clientSecret => _clientSecret;

  Future<String> createPaymentIntent({
    required int bookingId,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _clientSecret = await _repository.createPaymentIntent(
        bookingId: bookingId,
        amount: amount,
      );

      _isLoading = false;
      notifyListeners();
      return _clientSecret!;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> confirmPayment(String paymentIntentId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.confirmPayment(paymentIntentId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> confirmPayOnPickup({required int bookingId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.confirmPayOnPickup(bookingId: bookingId);

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



