import '../entities/ingreso.dart';
import '../repositories/pago_repository.dart';

class RegistrarCobroDeudaUseCase {
  final PagoRepository repository;
  RegistrarCobroDeudaUseCase(this.repository);

  Future<Ingreso> execute({
    required int deudaId,
    required int pacienteId,
    required int ciudadId,
    required double monto,
    required String metodo,
    String? notas,
  }) => repository.registrarCobroDeuda(
        deudaId: deudaId,
        pacienteId: pacienteId,
        ciudadId: ciudadId,
        monto: monto,
        metodo: metodo,
        notas: notas,
      );
}
