import '../repositories/paciente_repository.dart';

class ModificarPacienteUseCase {
  final PacienteRepository repository;
  ModificarPacienteUseCase(this.repository);

  Future<void> execute({
    required int id,
    required String ci,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  }) => repository.modificarPaciente(
    id: id,
    ci: ci,
    edad: edad,
    telefono: telefono,
    fechaNacimiento: fechaNacimiento,
    ciudadId: ciudadId,
  );
}
