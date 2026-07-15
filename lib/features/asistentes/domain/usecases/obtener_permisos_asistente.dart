import '../repositories/asistente_repository.dart';

class ObtenerPermisosAsistenteUseCase {
  final AsistenteRepository repository;

  ObtenerPermisosAsistenteUseCase(this.repository);

  Future<Map<String, bool>> execute(int id) => repository.obtenerPermisos(id);
}
