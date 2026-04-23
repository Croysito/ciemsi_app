import 'package:dio/dio.dart';
import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:ciemsi_app/core/services/auth_storage_service.dart';
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
      final usuarioJson = response.data['usuario'];
      final usuario = UsuarioModel.fromJson(usuarioJson);

      // Guardar token en el cliente
      apiClient.setToken(token);

      // Guardar sesión de forma segura
      await AuthStorageService.guardarSesion(
        token: token,
        usuario: usuarioJson,
      );

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
      // Eliminar sesión guardada
      await AuthStorageService.eliminarSesion();
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al cerrar sesión');
    }
  }
}
