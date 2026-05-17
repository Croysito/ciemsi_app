import '../entities/tratamiento.dart';
import '../repositories/tratamiento_repository.dart';

class ListarTratamientosUseCase {
  final TratamientoRepository repository;

  ListarTratamientosUseCase(this.repository);

  Future<List<Tratamiento>> execute() => repository.listarTratamientos();
}
