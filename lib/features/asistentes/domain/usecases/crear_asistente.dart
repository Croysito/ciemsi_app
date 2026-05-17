import '../entities/asistente_registro_result.dart';
import '../repositories/asistente_repository.dart';

class CrearAsistenteUseCase {
  final AsistenteRepository repository;

  CrearAsistenteUseCase(this.repository);

  Future<AsistenteRegistroResult> execute({
    required String nombre,
    required String apellido,
    required String email,
    required String ci,
    required int ciudadId,
  }) => repository.crearAsistente(
    nombre: nombre,
    apellido: apellido,
    email: email,
    ci: ci,
    ciudadId: ciudadId,
  );
}
