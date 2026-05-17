import '../entities/tratamiento_asignado.dart';
import '../repositories/tratamiento_repository.dart';

class ListarTratamientosAsignadosByCitaUseCase {
  final TratamientoRepository repository;

  ListarTratamientosAsignadosByCitaUseCase(this.repository);

  Future<List<TratamientoAsignado>> execute(int citaId) =>
      repository.listarAsignadosByCita(citaId);
}
