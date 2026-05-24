import '../entities/compra_producto.dart';
import '../repositories/pago_repository.dart';

class ListarComprasProductoUseCase {
  final PagoRepository repository;
  ListarComprasProductoUseCase(this.repository);

  Future<List<CompraProducto>> execute({int? ciudadId}) =>
      repository.listarComprasProducto(ciudadId: ciudadId);
}
