import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<bool> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        try {
          _user = await _authRepository.getCurrentUser();
          _isAuthenticated = true;
        } catch (e) {
          // If token is invalid (403/401), clear auth state
          if (e.toString().contains('403') || e.toString().contains('401')) {
            await _authService.clearAuthToken();
            _isAuthenticated = false;
            _user = null;
          } else {
            rethrow;
          }
        }
      } else {
        _isAuthenticated = false;
      }

      _isLoading = false;
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithGoogle();
      _user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyUserId, _user!.id);
      await prefs.setString(
          AppConstants.keyUserData, _user!.toJson().toString());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<void> sendOTP(String phoneNumber) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithPhone(phoneNumber);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> verifyOTP(String phoneNumber, String otp) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.verifyPhoneOTP(phoneNumber, otp);
      _user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyUserId, _user!.id);
      await prefs.setString(
          AppConstants.keyUserData, _user!.toJson().toString());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.clearAuthToken();
      await _authRepository.logout();
      _user = null;
      _isAuthenticated = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}



