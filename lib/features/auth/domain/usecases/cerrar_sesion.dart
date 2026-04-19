import '../repositories/auth_repository.dart';

class CerrarSesionUseCase {
  final AuthRepository repository;

  CerrarSesionUseCase(this.repository);

  Future<void> execute() {
    return repository.cerrarSesion();
  }
}
