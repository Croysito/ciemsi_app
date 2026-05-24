import '../../domain/entities/ingreso.dart';
import '../../domain/entities/deuda.dart';
import '../../domain/entities/estado_cuenta.dart';
import '../../domain/entities/producto.dart';
import '../../domain/entities/compra_producto.dart';
import '../../domain/entities/producto_inventario_item.dart';
import '../../domain/repositories/pago_repository.dart';
import '../datasources/pago_remote_datasource.dart';

class PagoRepositoryImpl implements PagoRepository {
  final PagoRemoteDatasource remoteDatasource;
  PagoRepositoryImpl(this.remoteDatasource);

  @override
  Future<EstadoCuenta> obtenerEstadoCuenta(int pacienteId) =>
      remoteDatasource.obtenerEstadoCuenta(pacienteId);

  @override
  Future<List<Deuda>> listarDeudas(int pacienteId) =>
      remoteDatasource.listarDeudas(pacienteId);

  @override
  Future<Ingreso> registrarCobroDeuda({
    required int deudaId,
    required int pacienteId,
    required int ciudadId,
    required double monto,
    required String metodo,
    String? notas,
  }) => remoteDatasource.registrarCobroDeuda(
    deudaId: deudaId,
    pacienteId: pacienteId,
    ciudadId: ciudadId,
    monto: monto,
    metodo: metodo,
    notas: notas,
  );

  @override
  Future<Ingreso> registrarVentaProducto({
    required int pacienteId,
    required int ciudadId,
    required List<Map<String, dynamic>> items,
    required String metodo,
    String? notas,
  }) => remoteDatasource.registrarVentaProducto(
    pacienteId: pacienteId,
    ciudadId: ciudadId,
    items: items,
    metodo: metodo,
    notas: notas,
  );

  @override
  Future<List<Producto>> listarProductos() =>
      remoteDatasource.listarProductos();

  @override
  Future<List<ProductoInventarioItem>> listarInventarioProductos(
    int ciudadId,
  ) => remoteDatasource.listarInventarioProductos(ciudadId);

  @override
  Future<Producto> crearProducto({
    required String nombre,
    String? descripcion,
    required String unidadMedida,
    required double precioVenta,
    required int umbral,
  }) => remoteDatasource.crearProducto(
    nombre: nombre,
    descripcion: descripcion,
    unidadMedida: unidadMedida,
    precioVenta: precioVenta,
    umbral: umbral,
  );

  @override
  Future<void> modificarProducto({
    required int id,
    required String nombre,
    String? descripcion,
    required String unidadMedida,
    required double precioVenta,
    required int umbral,
    required bool estado,
  }) => remoteDatasource.modificarProducto(
    id: id,
    nombre: nombre,
    descripcion: descripcion,
    unidadMedida: unidadMedida,
    precioVenta: precioVenta,
    umbral: umbral,
    estado: estado,
  );

  @override
  Future<bool> cambiarEstadoProducto(int id) =>
      remoteDatasource.cambiarEstadoProducto(id);

  @override
  Future<List<CompraProducto>> listarComprasProducto({int? ciudadId}) =>
      remoteDatasource.listarComprasProducto(ciudadId: ciudadId);

  @override
  Future<void> registrarCompraProducto({
    required int ciudadId,
    required String fecha,
    required List<Map<String, dynamic>> items,
  }) => remoteDatasource.registrarCompraProducto(
    ciudadId: ciudadId,
    fecha: fecha,
    items: items,
  );

  @override
  Future<List<Map<String, dynamic>>> listarCiudades() =>
      remoteDatasource.listarCiudades();

  @override
  Future<Map<String, dynamic>> obtenerMiPerfilPaciente() =>
      remoteDatasource.obtenerMiPerfilPaciente();
}
