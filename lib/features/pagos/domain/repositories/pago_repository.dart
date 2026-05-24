import '../entities/ingreso.dart';
import '../entities/deuda.dart';
import '../entities/estado_cuenta.dart';
import '../entities/producto.dart';
import '../entities/compra_producto.dart';
import '../entities/producto_inventario_item.dart';

abstract class PagoRepository {
  Future<EstadoCuenta> obtenerEstadoCuenta(int pacienteId);
  Future<List<Deuda>> listarDeudas(int pacienteId);
  Future<Ingreso> registrarCobroDeuda({
    required int deudaId,
    required int pacienteId,
    required int ciudadId,
    required double monto,
    required String metodo,
    String? notas,
  });
  Future<Ingreso> registrarVentaProducto({
    required int pacienteId,
    required int ciudadId,
    required List<Map<String, dynamic>> items,
    required String metodo,
    String? notas,
  });
  Future<List<Producto>> listarProductos();
  Future<List<ProductoInventarioItem>> listarInventarioProductos(int ciudadId);
  Future<Producto> crearProducto({
    required String nombre,
    String? descripcion,
    required String unidadMedida,
    required double precioVenta,
    required int umbral,
  });
  Future<void> modificarProducto({
    required int id,
    required String nombre,
    String? descripcion,
    required String unidadMedida,
    required double precioVenta,
    required int umbral,
    required bool estado,
  });
  Future<bool> cambiarEstadoProducto(int id);
  Future<List<CompraProducto>> listarComprasProducto({int? ciudadId});
  Future<void> registrarCompraProducto({
    required int ciudadId,
    required String fecha,
    required List<Map<String, dynamic>> items,
  });
  Future<List<Map<String, dynamic>>> listarCiudades();
  Future<Map<String, dynamic>> obtenerMiPerfilPaciente();
}
