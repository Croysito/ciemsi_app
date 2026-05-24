import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import '../../domain/entities/asistente.dart';
import '../../domain/entities/asistente_registro_result.dart';
import '../../domain/repositories/asistente_repository.dart';
import '../datasources/asistente_remote_datasource.dart';

class AsistenteRepositoryImpl implements AsistenteRepository {
  final AsistenteRemoteDatasource remoteDatasource;

  AsistenteRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Asistente>> listarAsistentes() =>
      remoteDatasource.listarAsistentes();

  @override
  Future<List<Ciudad>> listarCiudades() => remoteDatasource.listarCiudades();

  @override
  Future<AsistenteRegistroResult> crearAsistente({
    required String nombre,
    required String apellido,
    required String email,
    required String ci,
    required int ciudadId,
  }) async {
    final resultado = await remoteDatasource.crearAsistente(
      nombre: nombre,
      apellido: apellido,
      email: email,
      ci: ci,
      ciudadId: ciudadId,
    );
    final credenciales = resultado['credenciales'];
    return AsistenteRegistroResult(
      email: credenciales['email'],
      password: credenciales['password'],
    );
  }

  @override
  Future<void> modificarAsistente({
    required int id,
    required String nombre,
    required String apellido,
    required String email,
    required int ciudadId,
  }) => remoteDatasource.modificarAsistente(
    id: id,
    nombre: nombre,
    apellido: apellido,
    email: email,
    ciudadId: ciudadId,
  );

  @override
  Future<void> cambiarEstado(int id, bool estado) =>
      remoteDatasource.cambiarEstado(id, estado);

  @override
  Future<void> cambiarPassword({
    required String passwordActual,
    required String passwordNuevo,
  }) => remoteDatasource.cambiarPassword(
    passwordActual: passwordActual,
    passwordNuevo: passwordNuevo,
  );
}
