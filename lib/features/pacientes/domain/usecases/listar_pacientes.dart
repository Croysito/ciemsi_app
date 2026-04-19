import '../entities/paciente.dart';
import '../repositories/paciente_repository.dart';

class ListarPacientesUseCase {
  final PacienteRepository repository;
  ListarPacientesUseCase(this.repository);

  Future<List<Paciente>> execute() => repository.listarPacientes();
}
