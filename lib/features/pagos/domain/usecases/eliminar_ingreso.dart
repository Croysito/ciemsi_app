import '../repositories/pago_repository.dart';

class EliminarIngresoUseCase {
  final PagoRepository repository;
  EliminarIngresoUseCase(this.repository);

  Future<void> execute(int id) => repository.eliminarIngreso(id);
}
