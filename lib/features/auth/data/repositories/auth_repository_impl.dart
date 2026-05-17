import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<AuthSession> iniciarSesion(String email, String password) async {
    return await remoteDatasource.iniciarSesion(email, password);
  }

  @override
  Future<void> recuperarContrasena(String email) async {
    await remoteDatasource.recuperarContrasena(email);
  }

  @override
  Future<void> cerrarSesion() async {
    await remoteDatasource.cerrarSesion();
  }
}
