import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final response = await _apiClient.post(
      '/auth/google',
      data: {'idToken': idToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithFacebook(String accessToken) async {
    final response = await _apiClient.post(
      '/auth/facebook',
      data: {'accessToken': accessToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    final response = await _apiClient.post(
      '/auth/send-otp',
      data: {'phone': phoneNumber},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-otp',
        data: {'phone': phoneNumber, 'otp': otp},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Auth repository error: $e');
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me');
    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }
}



