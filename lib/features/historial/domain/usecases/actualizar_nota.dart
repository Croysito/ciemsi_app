import '../entities/nota_evolucion.dart';
import '../repositories/historial_repository.dart';

class ActualizarNotaUseCase {
  final HistorialRepository repository;
  ActualizarNotaUseCase(this.repository);

  Future<NotaEvolucion> execute({
    required int notaId,
    required String detalle,
  }) => repository.actualizarNota(notaId: notaId, detalle: detalle);
}
