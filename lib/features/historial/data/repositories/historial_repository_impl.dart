import '../../domain/entities/historial_clinico.dart';
import '../../domain/entities/nota_evolucion.dart';
import '../../domain/entities/link_archivo.dart';
import '../../domain/repositories/historial_repository.dart';
import '../datasources/historial_remote_datasource.dart';

class HistorialRepositoryImpl implements HistorialRepository {
  final HistorialRemoteDatasource remoteDatasource;
  HistorialRepositoryImpl(this.remoteDatasource);

  @override
  Future<HistorialClinico> obtenerHistorial(int pacienteId) =>
      remoteDatasource.obtenerHistorial(pacienteId);

  @override
  Future<NotaEvolucion> agregarNota(int pacienteId, String detalle) =>
      remoteDatasource.agregarNota(pacienteId, detalle);

  @override
  Future<LinkArchivo> agregarLink({
    required int notaId,
    required String nombre,
    required String link,
    required String tipo,
  }) => remoteDatasource.agregarLink(
    notaId: notaId,
    nombre: nombre,
    link: link,
    tipo: tipo,
  );

  @override
  Future<LinkArchivo> subirArchivoDrive({
    required int notaId,
    required String tipo,
    required String tokens,
    required List<int> bytes,
    required String nombre,
    required String mimeType,
  }) => remoteDatasource.subirArchivoDrive(
    notaId: notaId,
    tipo: tipo,
    tokens: tokens,
    bytes: bytes,
    nombre: nombre,
    mimeType: mimeType,
  );

  @override
  Future<List<LinkArchivo>> obtenerLinksPorTipo(int notaId, String tipo) =>
      remoteDatasource.obtenerLinksPorTipo(notaId, tipo);
  @override
  Future<HistorialClinico> obtenerMiHistorial() =>
      remoteDatasource.obtenerMiHistorial();
}
