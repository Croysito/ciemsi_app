import '../../domain/entities/paciente.dart';
import '../../domain/entities/ciudad.dart';
import '../../domain/entities/registro_paciente_result.dart';
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
  Future<RegistroPacienteResult> registrarPaciente({
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    DateTime? fechaNacimiento,
    String? genero,
    required int ciudadId,
  }) => remoteDatasource.registrarPaciente(
    ci: ci,
    nombre: nombre,
    apellido: apellido,
    email: email,
    telefono: telefono,
    fechaNacimiento: fechaNacimiento,
    genero: genero,
    ciudadId: ciudadId,
  );

  @override
  Future<void> modificarPaciente({
    required int id,
    required String ci,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    DateTime? fechaNacimiento,
    String? genero,
    required int ciudadId,
  }) => remoteDatasource.modificarPaciente(
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

  @override
  Future<void> completarPaciente({
    required int id,
    required String ci,
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    DateTime? fechaNacimiento,
    String? genero,
    required int ciudadId,
  }) => remoteDatasource.completarPaciente(
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

  @override
  Future<List<Ciudad>> listarCiudades() => remoteDatasource.listarCiudades();
}
