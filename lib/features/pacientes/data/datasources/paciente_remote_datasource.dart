import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/registro_paciente_result.dart';
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
      throw Exception(ApiClient.errorMessage(e, 'Error al listar pacientes'));
    }
  }

  Future<PacienteModel> obtenerPaciente(int id) async {
    try {
      final response = await apiClient.dio.get('/pacientes/$id');
      return PacienteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al obtener paciente'));
    }
  }

  Future<RegistroPacienteResult> registrarPaciente({
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    DateTime? fechaNacimiento,
    String? genero,
    required int ciudadId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/pacientes',
        data: {
          'ci': ci,
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'telefono': telefono,
          'fechaNacimiento': fechaNacimiento?.toIso8601String(),
          'genero': genero,
          'ciudadId': ciudadId,
        },
      );
      final credenciales = response.data['credenciales'];
      return RegistroPacienteResult(
        email: credenciales['email'],
        password: credenciales['password'],
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al registrar paciente'));
    }
  }

  Future<void> modificarPaciente({
    required int id,
    required String ci,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    DateTime? fechaNacimiento,
    String? genero,
    required int ciudadId,
  }) async {
    try {
      await apiClient.dio.put(
        '/pacientes/$id',
        data: {
          'ci': ci,
          if (nombre != null) 'nombre': nombre,
          if (apellido != null) 'apellido': apellido,
          if (email != null) 'email': email,
          'telefono': telefono,
          'fechaNacimiento': fechaNacimiento?.toIso8601String(),
          'genero': genero,
          'ciudadId': ciudadId,
        },
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al modificar paciente'));
    }
  }

  Future<void> completarPaciente({
    required int id,
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    DateTime? fechaNacimiento,
    String? genero,
    required int ciudadId,
  }) async {
    try {
      await apiClient.dio.put(
        '/pacientes/$id/completar',
        data: {
          'ci': ci,
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'telefono': telefono,
          'fechaNacimiento': fechaNacimiento?.toIso8601String(),
          'genero': genero,
          'ciudadId': ciudadId,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        ApiClient.errorMessage(e, 'Error al completar datos del paciente'),
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
      throw Exception(ApiClient.errorMessage(e, 'Error al listar ciudades'));
    }
  }
}
