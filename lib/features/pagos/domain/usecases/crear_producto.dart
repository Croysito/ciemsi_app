import '../entities/producto.dart';
import '../repositories/pago_repository.dart';

class CrearProductoUseCase {
  final PagoRepository repository;
  CrearProductoUseCase(this.repository);

  Future<Producto> execute({
    required String nombre,
    String? descripcion,
    required String unidadMedida,
    required double precioVenta,
    required int umbral,
  }) =>
      repository.crearProducto(
        nombre: nombre,
        descripcion: descripcion,
        unidadMedida: unidadMedida,
        precioVenta: precioVenta,
        umbral: umbral,
      );
}
