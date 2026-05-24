import '../repositories/traslado_repository.dart';

class DevolverTrasladoUseCase {
  final TrasladoRepository repository;
  DevolverTrasladoUseCase(this.repository);

  Future<void> execute(int id) => repository.devolver(id);
}
