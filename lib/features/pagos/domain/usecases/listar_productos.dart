import '../entities/producto.dart';
import '../repositories/pago_repository.dart';

class ListarProductosUseCase {
  final PagoRepository repository;
  ListarProductosUseCase(this.repository);

  Future<List<Producto>> execute() => repository.listarProductos();
}
