import '../entities/cita_medica.dart';
import '../repositories/cita_repository.dart';

class ListarCitasUseCase {
  final CitaRepository repository;

  ListarCitasUseCase(this.repository);

  Future<List<CitaMedica>> execute() => repository.listarCitas();
}
