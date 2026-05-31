import '../entities/servicio.dart';
import '../repositories/servicio_repository.dart';

class ListarServiciosUseCase {
  final ServicioRepository repository;
  ListarServiciosUseCase(this.repository);

  Future<List<Servicio>> call() => repository.listar();
}
