import '../entities/registro_paciente_result.dart';
import '../repositories/paciente_repository.dart';

class RegistrarPacienteUseCase {
  final PacienteRepository repository;
  RegistrarPacienteUseCase(this.repository);

  Future<RegistroPacienteResult> execute({
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  }) => repository.registrarPaciente(
    ci: ci,
    nombre: nombre,
    apellido: apellido,
    email: email,
    telefono: telefono,
    fechaNacimiento: fechaNacimiento,
    ciudadId: ciudadId,
  );
}
