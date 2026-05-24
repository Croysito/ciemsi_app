import '../entities/estado_cuenta.dart';
import '../repositories/pago_repository.dart';

class ObtenerEstadoCuentaUseCase {
  final PagoRepository repository;
  ObtenerEstadoCuentaUseCase(this.repository);

  Future<EstadoCuenta> execute(int pacienteId) =>
      repository.obtenerEstadoCuenta(pacienteId);
}
