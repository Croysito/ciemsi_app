import '../entities/paciente.dart';
import '../entities/ciudad.dart';

abstract class PacienteRepository {
  Future<List<Paciente>> listarPacientes();
  Future<Paciente> obtenerPaciente(int id);
  Future<void> registrarPaciente({
    required String ci,
    required String nombre,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  });
  Future<void> modificarPaciente({
    required int id,
    required String ci,
    required String nombre,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  });
  Future<List<Ciudad>> listarCiudades();
}
