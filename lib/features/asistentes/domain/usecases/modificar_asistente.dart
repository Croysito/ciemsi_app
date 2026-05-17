import '../repositories/asistente_repository.dart';

class ModificarAsistenteUseCase {
  final AsistenteRepository repository;

  ModificarAsistenteUseCase(this.repository);

  Future<void> execute({
    required int id,
    required String nombre,
    required String apellido,
    required String email,
    required int ciudadId,
  }) => repository.modificarAsistente(
    id: id,
    nombre: nombre,
    apellido: apellido,
    email: email,
    ciudadId: ciudadId,
  );
}
