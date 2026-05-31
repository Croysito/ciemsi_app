import '../repositories/cita_repository.dart';

class ObtenerQrPagoUseCase {
  final CitaRepository repository;
  ObtenerQrPagoUseCase(this.repository);

  Future<Map<String, dynamic>> execute() => repository.obtenerQrPago();
}
