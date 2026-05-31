import '../repositories/paciente_repository.dart';

class CompletarPacienteUseCase {
  final PacienteRepository repository;
  CompletarPacienteUseCase(this.repository);

  Future<void> execute({
    required int id,
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    DateTime? fechaNacimiento,
    String? genero,
    required int ciudadId,
  }) => repository.completarPaciente(
        id: id,
        ci: ci,
        nombre: nombre,
        apellido: apellido,
        email: email,
        telefono: telefono,
        fechaNacimiento: fechaNacimiento,
        genero: genero,
        ciudadId: ciudadId,
      );
}
