import '../repositories/servicio_repository.dart';

class CrearServicioUseCase {
  final ServicioRepository repository;
  CrearServicioUseCase(this.repository);

  Future<void> call(Map<String, dynamic> datos) => repository.crear(datos);
}
