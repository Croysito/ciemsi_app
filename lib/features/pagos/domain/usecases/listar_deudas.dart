import '../entities/deuda.dart';
import '../repositories/pago_repository.dart';

class ListarDeudasUseCase {
  final PagoRepository repository;
  ListarDeudasUseCase(this.repository);

  Future<List<Deuda>> execute(int pacienteId) =>
      repository.listarDeudas(pacienteId);
}
