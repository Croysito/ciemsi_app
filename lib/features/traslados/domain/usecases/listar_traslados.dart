import '../entities/traslado.dart';
import '../repositories/traslado_repository.dart';

class ListarTrasladosUseCase {
  final TrasladoRepository repository;
  ListarTrasladosUseCase(this.repository);

  Future<List<Traslado>> execute(int ciudadId) => repository.listar(ciudadId);
}
