import '../repositories/paciente_repository.dart';

class RegistrarPacienteUseCase {
  final PacienteRepository repository;
  RegistrarPacienteUseCase(this.repository);

  Future<Map<String, dynamic>> execute({
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  }) => repository.registrarPaciente(
    ci: ci,
    nombre: nombre,
    apellido: apellido,
    email: email,
    edad: edad,
    telefono: telefono,
    fechaNacimiento: fechaNacimiento,
    ciudadId: ciudadId,
  );
}
