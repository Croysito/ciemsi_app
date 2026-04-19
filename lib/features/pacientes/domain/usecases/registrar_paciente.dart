import '../repositories/paciente_repository.dart';

class RegistrarPacienteUseCase {
  final PacienteRepository repository;
  RegistrarPacienteUseCase(this.repository);

  Future<void> execute({
    required String ci,
    required String nombre,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  }) => repository.registrarPaciente(
    ci: ci,
    nombre: nombre,
    edad: edad,
    telefono: telefono,
    fechaNacimiento: fechaNacimiento,
    ciudadId: ciudadId,
  );
}
