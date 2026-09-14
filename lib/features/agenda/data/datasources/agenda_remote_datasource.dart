import 'package:dio/dio.dart';
import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:ciemsi_app/features/agenda/data/models/agenda_model.dart';
import 'package:ciemsi_app/features/pacientes/data/models/ciudad_model.dart';

class AgendaRemoteDatasource {
  final ApiClient apiClient;
  AgendaRemoteDatasource(this.apiClient);

  Future<List<AgendaModel>> listarAgendas({int? ciudadId}) async {
    try {
      final response = await apiClient.dio.get(
        '/agenda',
        queryParameters: ciudadId != null ? {'ciudadId': ciudadId} : null,
      );
      final lista = response.data;
      if (lista is! List) return [];
      final agendas = <AgendaModel>[];
      for (final item in lista) {
        try {
          agendas.add(AgendaModel.fromJson(item));
        } catch (_) {
          // item corrupto: se descarta, igual que el comportamiento previo.
        }
      }
      return agendas;
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al listar agendas');
    }
  }

  Future<void> crearAgenda(Map<String, dynamic> datos) async {
    try {
      await apiClient.dio.post('/agenda', data: datos);
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al crear agenda');
    }
  }

  Future<void> cambiarEstado(int id, bool estado) async {
    try {
      await apiClient.dio.patch('/agenda/$id/estado', data: {'estado': estado});
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al cambiar estado de agenda',
      );
    }
  }

  Future<void> eliminarAgenda(int id) async {
    try {
      await apiClient.dio.delete('/agenda/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al eliminar agenda');
    }
  }

  Future<List<CiudadModel>> listarCiudades() async {
    try {
      final response = await apiClient.dio.get('/ciudades');
      return (response.data as List)
          .map((c) => CiudadModel(id: c['id'], nombreCiudad: c['nombreCiudad']))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al listar ciudades');
    }
  }
}
