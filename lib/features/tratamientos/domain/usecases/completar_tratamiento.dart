import '../repositories/tratamiento_repository.dart';

class CompletarTratamientoUseCase {
  final TratamientoRepository repository;

  CompletarTratamientoUseCase(this.repository);

  Future<void> execute(int id) => repository.completarTratamiento(id);
}
