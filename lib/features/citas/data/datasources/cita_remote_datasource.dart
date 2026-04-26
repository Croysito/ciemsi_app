import 'package:dio/dio.dart';
import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:ciemsi_app/features/citas/data/models/cita_model.dart';
import 'package:ciemsi_app/features/agenda/data/models/agenda_model.dart';
import 'package:ciemsi_app/features/servicios/data/models/servicio_model.dart';

class CitaRemoteDatasource {
  final ApiClient apiClient;
  CitaRemoteDatasource(this.apiClient);

  Future<List<CitaModel>> listarCitas() async {
    try {
      final response = await apiClient.dio.get('/citas');
      return (response.data as List).map((c) => CitaModel.fromJson(c)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al listar citas');
    }
  }

  Future<Map<String, dynamic>> reservarCita({
    required String fecha,
    required String hora,
    required int servicioId,
    int? pacienteId,
    int? ciudadId,
    String? notas,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/citas',
        data: {
          'fecha': fecha,
          'hora': hora,
          'servicioId': servicioId,
          if (pacienteId != null) 'pacienteId': pacienteId,
          if (ciudadId != null) 'ciudadId': ciudadId,
          if (notas != null) 'notas': notas,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al reservar cita');
    }
  }

  Future<void> cambiarEstado(int id, String estado, {String? notas}) async {
    try {
      await apiClient.dio.patch(
        '/citas/$id/estado',
        data: {'estado': estado, if (notas != null) 'notas': notas},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al cambiar estado');
    }
  }

  Future<void> modificarCita({
    required int id,
    required String fecha,
    required String hora,
    required int servicioId,
    String? notas,
  }) async {
    try {
      await apiClient.dio.put(
        '/citas/$id',
        data: {
          'fecha': fecha,
          'hora': hora,
          'servicioId': servicioId,
          if (notas != null) 'notas': notas,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al modificar cita');
    }
  }

  Future<List<ServicioModel>> listarServicios() async {
    try {
      final response = await apiClient.dio.get('/servicios');
      return (response.data as List)
          .map((s) => ServicioModel.fromJson(s))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al listar servicios',
      );
    }
  }

  Future<Map<String, dynamic>> obtenerDisponibilidad({
    required int ciudadId,
    required String fecha,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/agenda/disponibilidad',
        queryParameters: {'ciudadId': ciudadId, 'fecha': fecha},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al obtener disponibilidad',
      );
    }
  }

  Future<List<AgendaModel>> listarAgenda(int ciudadId) async {
    try {
      final response = await apiClient.dio.get(
        '/agenda',
        queryParameters: {'ciudadId': ciudadId},
      );
      return (response.data as List)
          .map((a) => AgendaModel.fromJson(a))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al listar agenda');
    }
  }

  Future<void> crearAgenda({
    String? fecha,
    List<String>? diasSemana,
    required String horaInicio,
    required String horaFin,
    required int intervalo,
    required int ciudadId,
  }) async {
    try {
      await apiClient.dio.post(
        '/agenda',
        data: {
          if (fecha != null) 'fecha': fecha,
          if (diasSemana != null) 'diasSemana': diasSemana,
          'horaInicio': horaInicio,
          'horaFin': horaFin,
          'intervalo': intervalo,
          'ciudadId': ciudadId,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al crear agenda');
    }
  }

  Future<void> eliminarAgenda(int id) async {
    try {
      await apiClient.dio.delete('/agenda/$id');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al eliminar agenda',
      );
    }
  }
}
