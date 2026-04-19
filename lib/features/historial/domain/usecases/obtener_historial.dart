import '../entities/historial_clinico.dart';
import '../repositories/historial_repository.dart';

class ObtenerHistorialUseCase {
  final HistorialRepository repository;
  ObtenerHistorialUseCase(this.repository);

  Future<HistorialClinico> execute(int pacienteId) =>
      repository.obtenerHistorial(pacienteId);
}
