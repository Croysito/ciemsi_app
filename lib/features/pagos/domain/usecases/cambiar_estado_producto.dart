import '../repositories/pago_repository.dart';

class CambiarEstadoProductoUseCase {
  final PagoRepository repository;
  CambiarEstadoProductoUseCase(this.repository);

  Future<bool> execute(int id) => repository.cambiarEstadoProducto(id);
}
