import '../entities/historial_clinico.dart';
import '../repositories/historial_repository.dart';

class ObtenerMiHistorialUseCase {
  final HistorialRepository repository;

  ObtenerMiHistorialUseCase(this.repository);

  Future<HistorialClinico> execute() => repository.obtenerMiHistorial();
}
