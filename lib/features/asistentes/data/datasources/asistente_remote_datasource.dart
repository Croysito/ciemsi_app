import 'package:dio/dio.dart';
import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:ciemsi_app/features/asistentes/data/models/asistente_model.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class AsistenteRemoteDatasource {
  final ApiClient apiClient;
  AsistenteRemoteDatasource(this.apiClient);

  Future<List<AsistenteModel>> listarAsistentes() async {
    try {
      final response = await apiClient.dio.get('/asistentes');
      return (response.data as List)
          .map((a) => AsistenteModel.fromJson(a))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al listar asistentes',
      );
    }
  }

  Future<Map<String, dynamic>> crearAsistente({
    required String nombre,
    required String apellido,
    required String email,
    required String ci,
    required int ciudadId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/asistentes',
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'ci': ci,
          'ciudadId': ciudadId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al crear asistente',
      );
    }
  }

  Future<void> modificarAsistente({
    required int id,
    required String nombre,
    required String apellido,
    required String email,
    required int ciudadId,
  }) async {
    try {
      await apiClient.dio.put(
        '/asistentes/$id',
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'ciudadId': ciudadId,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al modificar asistente',
      );
    }
  }

  Future<void> cambiarEstado(int id, bool estado) async {
    try {
      await apiClient.dio.patch(
        '/asistentes/$id/estado',
        data: {'estado': estado},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al cambiar estado');
    }
  }

  Future<Map<String, bool>> obtenerPermisos(int id) async {
    try {
      final response = await apiClient.dio.get('/asistentes/$id/permisos');
      return (response.data as Map).map(
        (key, value) => MapEntry(key.toString(), value == true),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al obtener permisos',
      );
    }
  }

  Future<Map<String, bool>> actualizarPermisos(
    int id,
    Map<String, bool> permisos,
  ) async {
    try {
      final response = await apiClient.dio.put(
        '/asistentes/$id/permisos',
        data: {'permisos': permisos},
      );
      return (response.data as Map).map(
        (key, value) => MapEntry(key.toString(), value == true),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al actualizar permisos',
      );
    }
  }

  Future<List<Ciudad>> listarCiudades() async {
    try {
      final response = await apiClient.dio.get('/ciudades');
      return (response.data as List)
          .map((c) => Ciudad(id: c['id'], nombreCiudad: c['nombreCiudad']))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al cargar ciudades',
      );
    }
  }

  Future<void> cambiarPassword({
    required String passwordActual,
    required String passwordNuevo,
  }) async {
    try {
      await apiClient.dio.post(
        '/asistentes/cambiar-password',
        data: {
          'passwordActual': passwordActual,
          'passwordNuevo': passwordNuevo,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al cambiar contraseña',
      );
    }
  }
}
