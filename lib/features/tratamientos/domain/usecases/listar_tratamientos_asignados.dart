import '../entities/tratamiento_asignado.dart';
import '../repositories/tratamiento_repository.dart';

class ListarTratamientosAsignadosUseCase {
  final TratamientoRepository repository;

  ListarTratamientosAsignadosUseCase(this.repository);

  Future<List<TratamientoAsignado>> execute() => repository.listarAsignados();
}
