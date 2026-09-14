import '../entities/ciudad_inventario.dart';
import '../repositories/suministro_repository.dart';

class ListarCiudadesInventarioUseCase {
  final SuministroRepository repository;
  ListarCiudadesInventarioUseCase(this.repository);

  Future<List<CiudadInventario>> execute() => repository.listarCiudadesInventario();
}
