import '../repositories/cita_repository.dart';

class ConfirmarPagoCitaUseCase {
  final CitaRepository repository;
  ConfirmarPagoCitaUseCase(this.repository);

  Future<void> execute(int citaId) => repository.confirmarPago(citaId);
}
