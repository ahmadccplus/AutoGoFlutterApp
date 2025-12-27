import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AuthRepository _repository = AuthRepository();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _initialize();
  }

  /// Initialize and check authentication status
  Future<void> _initialize() async {
    await checkAuthStatus();
  }

  /// Check authentication status
  Future<bool> checkAuthStatus() async {
    try {
      _setLoading(true);
      _clearError();

      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        try {
          _user = await _repository.getCurrentUser();
          _isAuthenticated = true;
        } catch (e) {
          // If token is invalid, clear auth state
          if (e.toString().contains('401') || e.toString().contains('403')) {
            await _authService.signOut();
            _isAuthenticated = false;
            _user = null;
          } else {
            rethrow;
          }
        }
      } else {
        _isAuthenticated = false;
        _user = null;
      }

      _setLoading(false);
      return _isAuthenticated;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      _isAuthenticated = false;
      _user = null;
      return false;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signInWithGoogle();
      _user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      _isAuthenticated = true;

      await _saveUserToPrefs(_user!);
      _setLoading(false);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setError(errorMessage);
      _setLoading(false);
      _isAuthenticated = false;
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signUpWithEmailPassword(
        email,
        password,
        name,
      );
      
      _user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      _isAuthenticated = true;

      await _saveUserToPrefs(_user!);
      _setLoading(false);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setError(errorMessage);
      _setLoading(false);
      _isAuthenticated = false;
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.signInWithEmailPassword(email, password);
      _user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      _isAuthenticated = true;

      await _saveUserToPrefs(_user!);
      _setLoading(false);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setError(errorMessage);
      _setLoading(false);
      _isAuthenticated = false;
      rethrow;
    }
  }

  /// Send phone verification code
  Future<void> sendOTP(String phoneNumber) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendPhoneVerificationCode(phoneNumber);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Verify phone OTP
  Future<void> verifyOTP(String smsCode) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authService.verifyPhoneOTP(smsCode);
      _user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      _isAuthenticated = true;

      await _saveUserToPrefs(_user!);
      _setLoading(false);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setError(errorMessage);
      _setLoading(false);
      _isAuthenticated = false;
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _setLoading(true);

      await _authService.signOut();
      await _repository.logout();
      
      _user = null;
      _isAuthenticated = false;
      _clearError();

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _saveUserToPrefs(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyUserId, user.id);
      // Note: SharedPreferences doesn't support Map, so we'd need to serialize
      // For now, the token is saved in AuthService
    } catch (e) {
      print('Error saving user to prefs: $e');
    }
  }
}
