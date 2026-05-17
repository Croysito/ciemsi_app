import '../repositories/asistente_repository.dart';

class CambiarPasswordAsistenteUseCase {
  final AsistenteRepository repository;

  CambiarPasswordAsistenteUseCase(this.repository);

  Future<void> execute({
    required String passwordActual,
    required String passwordNuevo,
  }) => repository.cambiarPassword(
    passwordActual: passwordActual,
    passwordNuevo: passwordNuevo,
  );
}
