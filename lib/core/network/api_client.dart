import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late Dio _dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.keyAuthToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 (Unauthorized) or 403 (Forbidden) - token invalid
          if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
            // Clear invalid token
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(AppConstants.keyAuthToken);
            await prefs.remove(AppConstants.keyUserId);
            await prefs.remove(AppConstants.keyUserData);
            print('Token invalid, cleared from storage');
          }
          // Log detailed error for debugging
          print('API Error Details:');
          print('  Path: ${error.requestOptions.path}');
          print('  Full URL: ${error.requestOptions.uri}');
          print('  Method: ${error.requestOptions.method}');
          print('  Base URL: ${error.requestOptions.baseUrl}');
          print('  Status Code: ${error.response?.statusCode}');
          print('  Response Data: ${error.response?.data}');
          print('  Error Type: ${error.type}');
          print('  Error Message: ${error.message}');
          
          // If response is null, it's likely a connection error
          if (error.response == null) {
            print('  WARNING: No response received - connection may have failed');
            print('  Request data: ${error.requestOptions.data}');
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.delete(path, queryParameters: queryParameters);
  }
}



