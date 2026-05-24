import 'package:dio/dio.dart';
import 'package:ciemsi_app/core/network/api_client.dart';
import '../../domain/entities/traslado_ciudad_option.dart';
import '../../domain/entities/traslado_datos_creacion.dart';
import '../../domain/entities/traslado_item_option.dart';
import '../../domain/entities/traslado_stock.dart';
import '../models/traslado_model.dart';

class TrasladoRemoteDatasource {
  final ApiClient apiClient;
  TrasladoRemoteDatasource(this.apiClient);

  Future<List<TrasladoModel>> listar(int ciudadId) async {
    try {
      final res = await apiClient.dio.get(
        '/traslados',
        queryParameters: {'ciudadId': ciudadId},
      );
      return (res.data as List).map((e) => TrasladoModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al listar traslados',
      );
    }
  }

  Future<TrasladoDatosCreacion> obtenerDatosCreacion(int ciudadOrigenId) async {
    try {
      final results = await Future.wait([
        apiClient.dio.get('/suministros'),
        apiClient.dio.get('/productos'),
        apiClient.dio.get('/ciudades'),
      ]);

      final suministros = (results[0].data as List)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (item) => TrasladoItemOption(
              id: int.tryParse(item['id'].toString()) ?? 0,
              nombre: item['nombreSuministro']?.toString() ?? '',
            ),
          )
          .toList();

      final productos = (results[1].data as List)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (item) => TrasladoItemOption(
              id: int.tryParse(item['id'].toString()) ?? 0,
              nombre: item['nombre']?.toString() ?? '',
            ),
          )
          .toList();

      final ciudades = (results[2].data as List)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (item) => TrasladoCiudadOption(
              id: int.tryParse(item['id'].toString()) ?? 0,
              nombre:
                  item['nombreCiudad']?.toString() ??
                  item['nombre_ciudad']?.toString() ??
                  '',
            ),
          )
          .where((ciudad) => ciudad.id != ciudadOrigenId)
          .toList();

      return TrasladoDatosCreacion(
        suministros: suministros,
        productos: productos,
        ciudades: ciudades,
      );
    } on DioException catch (e) {
      throw Exception(
        ApiClient.errorMessage(e, 'Error al cargar datos del traslado'),
      );
    }
  }

  Future<TrasladoStock> consultarStock({
    required String tipo,
    required int itemId,
    required int ciudadOrigenId,
  }) async {
    try {
      final res = await apiClient.dio.get(
        '/traslados/stock',
        queryParameters: {
          'tipo': tipo,
          'itemId': itemId,
          'ciudadOrigenId': ciudadOrigenId,
        },
      );
      return TrasladoStock(
        disponible:
            double.tryParse(res.data['disponible']?.toString() ?? '0') ?? 0.0,
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al consultar stock'));
    }
  }

  Future<void> crear({
    required String tipo,
    int? suministroId,
    int? productoId,
    required int ciudadOrigenId,
    required int ciudadDestinoId,
    required double cantidad,
  }) async {
    try {
      await apiClient.dio.post(
        '/traslados',
        data: {
          'tipo': tipo,
          if (suministroId != null) 'suministroId': suministroId,
          if (productoId != null) 'productoId': productoId,
          'ciudadOrigenId': ciudadOrigenId,
          'ciudadDestinoId': ciudadDestinoId,
          'cantidad': cantidad,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al crear traslado');
    }
  }

  Future<void> confirmar(int id) async {
    try {
      await apiClient.dio.patch('/traslados/$id/confirmar');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al confirmar traslado',
      );
    }
  }

  Future<void> devolver(int id) async {
    try {
      await apiClient.dio.patch('/traslados/$id/devolver');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al devolver traslado',
      );
    }
  }
}
