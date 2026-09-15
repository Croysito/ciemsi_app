import '../entities/ingreso.dart';
import '../repositories/pago_repository.dart';

class EditarCobroDeudaUseCase {
  final PagoRepository repository;
  EditarCobroDeudaUseCase(this.repository);

  Future<Ingreso> execute({
    required int id,
    required double montoEfectivo,
    required double montoQr,
    String? notas,
  }) => repository.editarCobroDeuda(
        id: id,
        montoEfectivo: montoEfectivo,
        montoQr: montoQr,
        notas: notas,
      );
}
