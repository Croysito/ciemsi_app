import 'package:dio/dio.dart';
import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:ciemsi_app/features/suministros/data/models/suministro_model.dart';
import 'package:ciemsi_app/features/suministros/data/models/inventario_model.dart';

class SuministroRemoteDatasource {
  final ApiClient apiClient;
  SuministroRemoteDatasource(this.apiClient);

  Future<List<SuministroModel>> listarSuministros({String? tipo}) async {
    try {
      final response = await apiClient.dio.get(
        '/suministros',
        queryParameters: tipo != null ? {'tipo': tipo} : null,
      );
      return (response.data as List)
          .map((s) => SuministroModel.fromJson(s))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al listar suministros',
      );
    }
  }

  Future<Map<String, dynamic>> crearSuministro({
    required String nombreSuministro,
    required String unidadMedida,
    String? marca,
    required String tipo,
    required int umbral,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/suministros',
        data: {
          'nombreSuministro': nombreSuministro,
          'unidadMedida': unidadMedida,
          'marca': marca,
          'tipo': tipo,
          'umbral': umbral,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al crear suministro',
      );
    }
  }

  Future<void> modificarSuministro(int id, Map<String, dynamic> data) async {
    try {
      await apiClient.dio.put('/suministros/$id', data: data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al modificar suministro',
      );
    }
  }

  Future<Map<String, dynamic>> obtenerInventario(int ciudadId) async {
    try {
      final response = await apiClient.dio.get(
        '/suministros/inventario',
        queryParameters: {'ciudadId': ciudadId},
      );
      final inventario = (response.data['inventario'] as List)
          .map((i) => InventarioModel.fromJson(i))
          .toList();
      final stockBajo = (response.data['stockBajo'] as List)
          .map((i) => InventarioModel.fromJson(i))
          .toList();
      return {
        'inventario': inventario,
        'stockBajo': stockBajo,
        'totalItems': response.data['totalItems'],
      };
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al obtener inventario',
      );
    }
  }

  Future<Map<String, dynamic>> obtenerAlertas(int ciudadId) async {
    try {
      final response = await apiClient.dio.get(
        '/suministros/alertas',
        queryParameters: {'ciudadId': ciudadId},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al obtener alertas',
      );
    }
  }

  Future<Map<String, dynamic>> registrarCompra({
    required int ciudadId,
    required List<Map<String, dynamic>> items,
    String? fecha,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/compras',
        data: {
          'ciudadId': ciudadId,
          'items': items,
          if (fecha != null) 'fecha': fecha,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al registrar compra',
      );
    }
  }
}
