import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> iniciarSesion(String email, String password);
  Future<void> recuperarContrasena(String email);
  Future<void> cerrarSesion();
}
