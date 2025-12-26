import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../data/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository = AuthRepository();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      final result = await _repository.loginWithGoogle(idToken);
      await _saveAuthToken(result['token'] as String);
      return result;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  Future<Map<String, dynamic>> signInWithPhone(String phoneNumber) async {
    try {
      await _repository.sendOTP(phoneNumber);
      return {'success': true, 'message': 'OTP sent successfully'};
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<Map<String, dynamic>> verifyPhoneOTP(
      String phoneNumber, String otp) async {
    try {
      final result = await _repository.verifyOTP(phoneNumber, otp);
      if (result['success'] == true) {
        await _saveAuthToken(result['token'] as String);
        return result;
      } else {
        throw Exception(result['message'] as String? ?? 'OTP verification failed');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] as String? ?? 
                          e.message ?? 
                          'Network error. Please check your connection.';
      throw Exception('OTP verification failed: $errorMessage');
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAuthToken, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAuthToken);
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserData);
  }

  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}



