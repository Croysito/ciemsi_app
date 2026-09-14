import '../entities/ciudad_inventario.dart';
import '../entities/inventario_comparado.dart';
import '../repositories/suministro_repository.dart';

class ObtenerInventarioComparadoUseCase {
  final SuministroRepository repository;
  ObtenerInventarioComparadoUseCase(this.repository);

  Future<InventarioComparado> execute(List<CiudadInventario> ciudades) =>
      repository.obtenerInventarioComparado(ciudades);
}
