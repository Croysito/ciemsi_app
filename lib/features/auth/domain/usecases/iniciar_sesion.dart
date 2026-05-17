import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class IniciarSesionUseCase {
  final AuthRepository repository;

  IniciarSesionUseCase(this.repository);

  Future<AuthSession> execute(String email, String password) {
    return repository.iniciarSesion(email, password);
  }
}
