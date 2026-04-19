import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/paciente_model.dart';
import '../models/ciudad_model.dart';

class PacienteRemoteDatasource {
  final ApiClient apiClient;
  PacienteRemoteDatasource(this.apiClient);

  Future<List<PacienteModel>> listarPacientes() async {
    try {
      final response = await apiClient.dio.get('/pacientes');
      return (response.data as List)
          .map((p) => PacienteModel.fromJson(p))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al listar pacientes',
      );
    }
  }

  Future<PacienteModel> obtenerPaciente(int id) async {
    try {
      final response = await apiClient.dio.get('/pacientes/$id');
      return PacienteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al obtener paciente',
      );
    }
  }

  Future<void> registrarPaciente({
    required String ci,
    required String nombre,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  }) async {
    try {
      await apiClient.dio.post(
        '/pacientes',
        data: {
          'ci': ci,
          'nombre': nombre,
          'edad': edad,
          'telefono': telefono,
          'fechaNacimiento': fechaNacimiento?.toIso8601String(),
          'ciudadId': ciudadId,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al registrar paciente',
      );
    }
  }

  Future<void> modificarPaciente({
    required int id,
    required String ci,
    required String nombre,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  }) async {
    try {
      await apiClient.dio.put(
        '/pacientes/$id',
        data: {
          'ci': ci,
          'nombre': nombre,
          'edad': edad,
          'telefono': telefono,
          'fechaNacimiento': fechaNacimiento?.toIso8601String(),
          'ciudadId': ciudadId,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al modificar paciente',
      );
    }
  }

  Future<List<CiudadModel>> listarCiudades() async {
    try {
      final response = await apiClient.dio.get('/ciudades');
      return (response.data as List)
          .map((c) => CiudadModel.fromJson(c))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al listar ciudades',
      );
    }
  }
}
