import '../repositories/asistente_repository.dart';

class ActualizarPermisosAsistenteUseCase {
  final AsistenteRepository repository;

  ActualizarPermisosAsistenteUseCase(this.repository);

  Future<Map<String, bool>> execute(int id, Map<String, bool> permisos) =>
      repository.actualizarPermisos(id, permisos);
}
