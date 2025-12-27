import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Repository for authentication API calls
class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  /// Authenticate with Firebase ID token
  /// This endpoint handles all Firebase authentication methods (Google, Email/Password, Phone)
  Future<Map<String, dynamic>> authenticateWithFirebase(
    String idToken, {
    String? name,
  }) async {
    try {
      final data = <String, dynamic>{
        'idToken': idToken,
      };
      
      if (name != null && name.isNotEmpty) {
        data['name'] = name;
      }

      print('Calling /auth/firebase endpoint with idToken length: ${idToken.length}');
      final response = await _apiClient.post(
        '/auth/firebase',
        data: data,
      );
      print('Response received: statusCode=${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Authentication failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle DioException specifically
      String errorMessage = 'Authentication failed';
      
      if (e.response != null) {
        // Server responded with error
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'] as String;
        } else {
          errorMessage = 'Server error: $statusCode';
        }
        
        print('Auth repository DioException: $statusCode - $errorMessage');
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
        print('Auth repository timeout error');
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Please ensure the backend is running.';
        print('Auth repository connection error: ${e.message}');
      } else {
        errorMessage = e.message ?? 'Network error occurred';
        print('Auth repository DioException: ${e.type} - ${e.message}');
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('Auth repository error: $e');
      rethrow;
    }
  }

  /// Get current user
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get current user: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to get current user';
      
      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'] as String;
        }
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('Get current user error: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      print('Logout error: $e');
      // Don't throw - logout should succeed even if backend call fails
    }
  }
}
