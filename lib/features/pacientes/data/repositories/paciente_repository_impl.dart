import '../../domain/entities/paciente.dart';
import '../../domain/entities/ciudad.dart';
import '../../domain/repositories/paciente_repository.dart';
import '../datasources/paciente_remote_datasource.dart';

class PacienteRepositoryImpl implements PacienteRepository {
  final PacienteRemoteDatasource remoteDatasource;
  PacienteRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Paciente>> listarPacientes() =>
      remoteDatasource.listarPacientes();

  @override
  Future<Paciente> obtenerPaciente(int id) =>
      remoteDatasource.obtenerPaciente(id);

  @override
  Future<void> registrarPaciente({
    required String ci,
    required String nombre,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  }) => remoteDatasource.registrarPaciente(
    ci: ci,
    nombre: nombre,
    edad: edad,
    telefono: telefono,
    fechaNacimiento: fechaNacimiento,
    ciudadId: ciudadId,
  );

  @override
  Future<void> modificarPaciente({
    required int id,
    required String ci,
    required String nombre,
    int? edad,
    String? telefono,
    DateTime? fechaNacimiento,
    required int ciudadId,
  }) => remoteDatasource.modificarPaciente(
    id: id,
    ci: ci,
    nombre: nombre,
    edad: edad,
    telefono: telefono,
    fechaNacimiento: fechaNacimiento,
    ciudadId: ciudadId,
  );

  @override
  Future<List<Ciudad>> listarCiudades() => remoteDatasource.listarCiudades();
}
