import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/ingreso_model.dart';
import '../models/deuda_model.dart';
import '../models/estado_cuenta_model.dart';
import '../models/producto_model.dart';
import '../models/producto_inventario_item_model.dart';
import '../models/compra_producto_model.dart';

class PagoRemoteDatasource {
  final ApiClient apiClient;
  PagoRemoteDatasource(this.apiClient);

  Future<EstadoCuentaModel> obtenerEstadoCuenta(int pacienteId) async {
    try {
      final response = await apiClient.dio.get(
        '/ingresos/estado-cuenta/$pacienteId',
      );
      return EstadoCuentaModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        ApiClient.errorMessage(e, 'Error al obtener estado de cuenta'),
      );
    }
  }

  Future<List<DeudaModel>> listarDeudas(int pacienteId) async {
    try {
      final response = await apiClient.dio.get(
        '/deudas',
        queryParameters: {'pacienteId': pacienteId},
      );
      return (response.data as List)
          .map((d) => DeudaModel.fromJson(d as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al listar deudas'));
    }
  }

  Future<IngresoModel> registrarCobroDeuda({
    required int deudaId,
    required int pacienteId,
    required int ciudadId,
    required double monto,
    required String metodo,
    String? notas,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/ingresos/cobro-deuda',
        data: {
          'deudaId': deudaId,
          'pacienteId': pacienteId,
          'ciudadId': ciudadId,
          'monto': monto,
          'metodo': metodo,
          'notas': ?notas,
        },
      );
      return IngresoModel.fromJson(
        response.data['ingreso'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al registrar cobro'));
    }
  }

  Future<IngresoModel> registrarVentaProducto({
    required int pacienteId,
    required int ciudadId,
    required List<Map<String, dynamic>> items,
    required String metodo,
    String? notas,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/ingresos/venta-producto',
        data: {
          'pacienteId': pacienteId,
          'ciudadId': ciudadId,
          'items': items,
          'metodo': metodo,
          'notas': ?notas,
        },
      );
      return IngresoModel.fromJson(
        response.data['ingreso'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al registrar venta'));
    }
  }

  Future<List<ProductoModel>> listarProductos() async {
    try {
      final response = await apiClient.dio.get('/productos');
      return (response.data as List)
          .map((p) => ProductoModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al listar productos'));
    }
  }

  Future<List<ProductoInventarioItemModel>> listarInventarioProductos(
    int ciudadId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/productos/inventario/$ciudadId',
      );
      return (response.data as List)
          .map(
            (item) => ProductoInventarioItemModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al cargar productos'));
    }
  }

  Future<ProductoModel> crearProducto({
    required String nombre,
    String? descripcion,
    required String unidadMedida,
    required double precioVenta,
    required int umbral,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/productos',
        data: {
          'nombre': nombre,
          'descripcion': ?descripcion,
          'unidadMedida': unidadMedida,
          'precioVenta': precioVenta,
          'umbral': umbral,
        },
      );
      return ProductoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al crear producto'));
    }
  }

  Future<void> modificarProducto({
    required int id,
    required String nombre,
    String? descripcion,
    required String unidadMedida,
    required double precioVenta,
    required int umbral,
    required bool estado,
  }) async {
    try {
      await apiClient.dio.put(
        '/productos/$id',
        data: {
          'nombre': nombre,
          'descripcion': descripcion,
          'unidadMedida': unidadMedida,
          'precioVenta': precioVenta,
          'umbral': umbral,
          'estado': estado,
        },
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al modificar producto'));
    }
  }

  Future<bool> cambiarEstadoProducto(int id) async {
    try {
      final response = await apiClient.dio.patch('/productos/$id/estado');
      return response.data['estado'] as bool;
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al cambiar estado'));
    }
  }

  Future<List<CompraProductoModel>> listarComprasProducto({
    int? ciudadId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/productos/compras',
        queryParameters: ciudadId != null ? {'ciudadId': ciudadId} : null,
      );
      return (response.data as List)
          .map((c) => CompraProductoModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al listar compras'));
    }
  }

  Future<void> registrarCompraProducto({
    required int ciudadId,
    required String fecha,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      await apiClient.dio.post(
        '/productos/compras',
        data: {'ciudadId': ciudadId, 'fecha': fecha, 'items': items},
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al registrar compra'));
    }
  }

  Future<List<Map<String, dynamic>>> listarCiudades() async {
    try {
      final response = await apiClient.dio.get('/ciudades');
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al cargar ciudades'));
    }
  }

  Future<Map<String, dynamic>> obtenerMiPerfilPaciente() async {
    try {
      final response = await apiClient.dio.get('/pacientes/mi-perfil');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        ApiClient.errorMessage(e, 'Error al obtener perfil del paciente'),
      );
    }
  }
}
