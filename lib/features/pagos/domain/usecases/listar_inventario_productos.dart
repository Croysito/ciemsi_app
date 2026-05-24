import '../entities/producto_inventario_item.dart';
import '../repositories/pago_repository.dart';

class ListarInventarioProductosUseCase {
  final PagoRepository repository;

  ListarInventarioProductosUseCase(this.repository);

  Future<List<ProductoInventarioItem>> execute(int ciudadId) =>
      repository.listarInventarioProductos(ciudadId);
}
