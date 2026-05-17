import '../entities/ciudad.dart';
import '../repositories/paciente_repository.dart';

class ListarCiudadesUseCase {
  final PacienteRepository repository;

  ListarCiudadesUseCase(this.repository);

  Future<List<Ciudad>> execute() => repository.listarCiudades();
}
