import '../repositories/pago_repository.dart';

class ModificarProductoUseCase {
  final PagoRepository repository;
  ModificarProductoUseCase(this.repository);

  Future<void> execute({
    required int id,
    required String nombre,
    String? descripcion,
    required String unidadMedida,
    required double precioVenta,
    required int umbral,
    required bool estado,
  }) =>
      repository.modificarProducto(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        unidadMedida: unidadMedida,
        precioVenta: precioVenta,
        umbral: umbral,
        estado: estado,
      );
}
