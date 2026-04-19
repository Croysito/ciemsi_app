import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class IniciarSesionUseCase {
  final AuthRepository repository;

  IniciarSesionUseCase(this.repository);

  Future<Map<String, dynamic>> execute(String email, String password) {
    return repository.iniciarSesion(email, password);
  }
}
