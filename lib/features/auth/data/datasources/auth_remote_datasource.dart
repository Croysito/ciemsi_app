import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/usuario_model.dart';

class AuthRemoteDatasource {
  final ApiClient apiClient;

  AuthRemoteDatasource(this.apiClient);

  Future<Map<String, dynamic>> iniciarSesion(
    String email,
    String password,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      final usuario = UsuarioModel.fromJson(response.data['usuario']);

      // Guardar token para futuros requests
      apiClient.setToken(token);

      return {'token': token, 'usuario': usuario};
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al iniciar sesión');
    }
  }

  Future<void> recuperarContrasena(String email) async {
    try {
      await apiClient.dio.post(
        '/auth/recuperar-contrasena',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al recuperar contraseña',
      );
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await apiClient.dio.post('/auth/logout');
      apiClient.removeToken();
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al cerrar sesión');
    }
  }
}
