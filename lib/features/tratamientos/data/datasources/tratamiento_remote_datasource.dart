import 'package:dio/dio.dart';
import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:ciemsi_app/features/tratamientos/data/models/tratamiento_model.dart';
import 'package:ciemsi_app/features/tratamientos/data/models/tratamiento_asignado_model.dart';

class TratamientoRemoteDatasource {
  final ApiClient apiClient;
  TratamientoRemoteDatasource(this.apiClient);

  Future<List<TratamientoModel>> listarTratamientos() async {
    try {
      final response = await apiClient.dio.get('/tratamientos');
      return (response.data as List)
          .map((t) => TratamientoModel.fromJson(t))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al listar tratamientos',
      );
    }
  }

  Future<Map<String, dynamic>> crearTratamiento({
    required String nombreTratamiento,
    String? detalle,
    double? precioBase,
    List<Map<String, dynamic>> medicamentosBase = const [],
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/tratamientos',
        data: {
          'nombreTratamiento': nombreTratamiento,
          'detalle': detalle,
          'precioBase': precioBase ?? 0,
          'medicamentosBase': medicamentosBase,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al crear tratamiento',
      );
    }
  }

  Future<Map<String, dynamic>> asignarTratamiento({
    required int tratamientoId,
    required int citaId,
    double? precio,
    List<Map<String, dynamic>>? medicamentos,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/tratamientos/asignar',
        data: {
          'tratamientoId': tratamientoId,
          'citaId': citaId,
          if (precio != null) 'precio': precio,
          if (medicamentos != null) 'medicamentos': medicamentos,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al asignar tratamiento',
      );
    }
  }

  Future<List<TratamientoAsignadoModel>> listarAsignados() async {
    try {
      final response = await apiClient.dio.get('/tratamientos/asignados');
      return (response.data as List)
          .map((t) => TratamientoAsignadoModel.fromJson(t))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al listar tratamientos asignados',
      );
    }
  }

  Future<List<TratamientoAsignadoModel>> listarAsignadosByCita(
    int citaId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/tratamientos/asignados/cita/$citaId',
      );
      return (response.data as List)
          .map((t) => TratamientoAsignadoModel.fromJson(t))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al obtener tratamientos',
      );
    }
  }

  Future<void> agregarSuministro({
    required int tratamientoAsignadoId,
    required int suministroId,
    required int cantidad,
  }) async {
    try {
      await apiClient.dio.post(
        '/tratamientos/asignados/$tratamientoAsignadoId/suministro',
        data: {'suministroId': suministroId, 'cantidad': cantidad},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al agregar suministro',
      );
    }
  }

  Future<void> completarTratamiento(int id) async {
    try {
      await apiClient.dio.patch('/tratamientos/asignados/$id/completar');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al completar tratamiento',
      );
    }
  }

  Future<Map<String, dynamic>> generarReceta({
    required int citaId,
    required String detalle,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/recetas',
        data: {'citaId': citaId, 'detalle': detalle},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al generar receta');
    }
  }

  Future<Map<String, dynamic>> obtenerWhatsappLink(int citaId) async {
    try {
      final response = await apiClient.dio.get(
        '/recetas/cita/$citaId/whatsapp',
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al obtener link');
    }
  }
}
