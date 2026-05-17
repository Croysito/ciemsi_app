import 'package:ciemsi_app/features/pacientes/domain/entities/paciente.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/registro_paciente_result.dart';

abstract class PacienteRepository {
  Future<List<Paciente>> listarPacientes();
  Future<Paciente> obtenerPaciente(int id);
  Future<RegistroPacienteResult> registrarPaciente({
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  });
  Future<void> modificarPaciente({
    required int id,
    required String ci,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  });
  Future<void> completarPaciente({
    required int id,
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  });
  Future<List<Ciudad>> listarCiudades();
}
