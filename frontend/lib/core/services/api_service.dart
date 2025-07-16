import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final Logger _logger = Logger();
  
  // Use different URLs for different platforms
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081'; // Web
    } else {
      return 'http://10.0.2.2:8081'; // Android emulator
      // For iOS simulator use: 'http://localhost:8081'
      // For physical device use your computer's IP address
    }
  }
  
  static String get hydrationBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8082'; // Web
    } else {
      return 'http://10.0.2.2:8082'; // Android emulator
      // For iOS simulator use: 'http://localhost:8082'
      // For physical device use your computer's IP address
    }
  }

  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d('Request: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('Response: ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Get stored token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Set token
  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Add auth header to request
  Future<void> _addAuthHeader(Dio dio) async {
    final token = await _getToken();
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Auth API Methods
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/api/v1/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/api/v1/login', data: {
        'username': username,
        'password': password,
      });
      
      final data = response.data;
      if (data['token'] != null) {
        await _setToken(data['token']);
      }
      
      return data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      await _addAuthHeader(_dio);
      final response = await _dio.get('/api/v1/profile');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  // Hydration API Methods
  Future<Map<String, dynamic>> createHydrationEntry({
    required int amount,
    required String type,
  }) async {
    try {
      final hydrationDio = Dio(BaseOptions(
        baseUrl: hydrationBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ));

      await _addAuthHeader(hydrationDio);
      
      final response = await hydrationDio.post('/api/v1/entries', data: {
        'amount': amount,
        'type': type,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getHydrationEntries() async {
    try {
      final hydrationDio = Dio(BaseOptions(
        baseUrl: hydrationBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ));

      await _addAuthHeader(hydrationDio);
      
      final response = await hydrationDio.get('/api/v1/entries');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getHydrationStats() async {
    try {
      final hydrationDio = Dio(BaseOptions(
        baseUrl: hydrationBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ));

      await _addAuthHeader(hydrationDio);
      
      final response = await hydrationDio.get('/api/v1/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateDailyGoal(int goal) async {
    try {
      final hydrationDio = Dio(BaseOptions(
        baseUrl: hydrationBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ));

      await _addAuthHeader(hydrationDio);
      
      final response = await hydrationDio.put('/api/v1/goal', data: {
        'goal': goal,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Error handling
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        if (statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (statusCode == 400) {
          if (data is Map && data['error'] != null) {
            return data['error'];
          }
          return 'Bad request. Please check your input.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Request failed with status code: $statusCode';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'An unexpected error occurred: ${error.message}';
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null;
  }

  // Check if backend is available
  Future<bool> isBackendAvailable() async {
    try {
      await _dio.get('/api/v1/profile', 
        options: Options(validateStatus: (status) => status! < 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null;
  }

  // Get current platform info for debugging
  String getPlatformInfo() {
    if (kIsWeb) {
      return 'Web';
    } else {
      return 'Mobile';
    }
  }

  // Get API URLs for current platform
  Map<String, String> getApiUrls() {
    return {
      'auth': baseUrl,
      'hydration': hydrationBaseUrl,
      'platform': getPlatformInfo(),
    };
  }
} 