import '../entities/asistente.dart';
import '../repositories/asistente_repository.dart';

class ListarAsistentesUseCase {
  final AsistenteRepository repository;

  ListarAsistentesUseCase(this.repository);

  Future<List<Asistente>> execute() => repository.listarAsistentes();
}
