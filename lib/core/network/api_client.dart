import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.1.4:3000/api';
  // Ejemplo: 'http://192.168.1.4:3000/api'

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

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeToken() {
    _dio.options.headers.remove('Authorization');
  }
}
