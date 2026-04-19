import '../entities/nota_evolucion.dart';
import '../repositories/historial_repository.dart';

class AgregarNotaUseCase {
  final HistorialRepository repository;
  AgregarNotaUseCase(this.repository);

  Future<NotaEvolucion> execute(int pacienteId, String detalle) =>
      repository.agregarNota(pacienteId, detalle);
}
