import '../repositories/asistente_repository.dart';

class CambiarEstadoAsistenteUseCase {
  final AsistenteRepository repository;

  CambiarEstadoAsistenteUseCase(this.repository);

  Future<void> execute(int id, bool estado) =>
      repository.cambiarEstado(id, estado);
}
