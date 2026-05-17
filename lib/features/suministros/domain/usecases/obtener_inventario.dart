import '../entities/inventario_result.dart';
import '../repositories/suministro_repository.dart';

class ObtenerInventarioUseCase {
  final SuministroRepository repository;

  ObtenerInventarioUseCase(this.repository);

  Future<InventarioResult> execute(int ciudadId) =>
      repository.obtenerInventario(ciudadId);
}
