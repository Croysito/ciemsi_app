import '../repositories/auth_repository.dart';

class RecuperarContrasenaUseCase {
  final AuthRepository repository;

  RecuperarContrasenaUseCase(this.repository);

  Future<void> execute(String email) {
    return repository.recuperarContrasena(email);
  }
}
