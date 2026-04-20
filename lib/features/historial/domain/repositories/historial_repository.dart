import '../entities/historial_clinico.dart';
import '../entities/nota_evolucion.dart';
import '../entities/link_archivo.dart';

abstract class HistorialRepository {
  Future<HistorialClinico> obtenerHistorial(int pacienteId);
  Future<NotaEvolucion> agregarNota(int pacienteId, String detalle);
  Future<LinkArchivo> agregarLink({
    required int notaId,
    required String nombre,
    required String link,
    required String tipo,
  });
  Future<LinkArchivo> subirArchivoDrive({
    required int notaId,
    required String tipo,
    required String tokens,
    required List<int> bytes,
    required String nombre,
    required String mimeType,
  });
  Future<List<LinkArchivo>> obtenerLinksPorTipo(int notaId, String tipo);
  Future<HistorialClinico> obtenerMiHistorial();
}
