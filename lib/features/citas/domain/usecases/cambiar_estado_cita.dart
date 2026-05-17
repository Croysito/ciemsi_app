import '../repositories/cita_repository.dart';

class CambiarEstadoCitaUseCase {
  final CitaRepository repository;

  CambiarEstadoCitaUseCase(this.repository);

  Future<void> execute(int id, String estado, {String? notas}) =>
      repository.cambiarEstado(id, estado, notas: notas);
}
