import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.6:3000/api',
  );
  // Ejemplo: 'http://172.17.39.200/api'

  final Dio _dio;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  Dio get dio => _dio;

  static String errorMessage(DioException exception, String fallback) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final mensaje = data['mensaje'] ?? data['message'] ?? data['error'];
      if (mensaje != null && mensaje.toString().trim().isNotEmpty) {
        return mensaje.toString();
      }
    }
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return fallback;
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeToken() {
    _dio.options.headers.remove('Authorization');
  }
}
