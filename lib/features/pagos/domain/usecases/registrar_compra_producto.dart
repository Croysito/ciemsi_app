import '../repositories/pago_repository.dart';

class RegistrarCompraProductoUseCase {
  final PagoRepository repository;
  RegistrarCompraProductoUseCase(this.repository);

  Future<void> execute({
    required int ciudadId,
    required String fecha,
    required List<Map<String, dynamic>> items,
  }) =>
      repository.registrarCompraProducto(
        ciudadId: ciudadId,
        fecha: fecha,
        items: items,
      );
}
