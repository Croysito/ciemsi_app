import '../entities/link_archivo.dart';
import '../repositories/historial_repository.dart';

class SubirArchivoDriveUseCase {
  final HistorialRepository repository;
  SubirArchivoDriveUseCase(this.repository);

  Future<LinkArchivo> execute({
    required int notaId,
    required String tipo,
    required String tokens,
    required List<int> bytes,
    required String nombre,
    required String mimeType,
  }) => repository.subirArchivoDrive(
    notaId: notaId,
    tipo: tipo,
    tokens: tokens,
    bytes: bytes,
    nombre: nombre,
    mimeType: mimeType,
  );
}
