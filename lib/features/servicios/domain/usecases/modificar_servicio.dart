import '../repositories/servicio_repository.dart';

class ModificarServicioUseCase {
  final ServicioRepository repository;
  ModificarServicioUseCase(this.repository);

  Future<void> call(int id, Map<String, dynamic> datos) =>
      repository.modificar(id, datos);
}
