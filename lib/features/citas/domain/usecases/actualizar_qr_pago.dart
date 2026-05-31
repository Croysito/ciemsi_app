import '../repositories/cita_repository.dart';

class ActualizarQrPagoUseCase {
  final CitaRepository repository;
  ActualizarQrPagoUseCase(this.repository);

  Future<void> execute(String qrLink) => repository.actualizarQrPago(qrLink);
}
