import '../entities/paciente.dart';
import '../entities/ciudad.dart';

abstract class PacienteRepository {
  Future<List<Paciente>> listarPacientes();
  Future<Paciente> obtenerPaciente(int id);
  Future<Map<String, dynamic>> registrarPaciente({
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  });
  Future<void> modificarPaciente({
    required int id,
    required String ci,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  });
  Future<List<Ciudad>> listarCiudades();
}
