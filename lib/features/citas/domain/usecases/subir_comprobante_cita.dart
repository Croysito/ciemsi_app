import 'dart:typed_data';
import '../repositories/cita_repository.dart';

class SubirComprobanteCitaUseCase {
  final CitaRepository repository;
  SubirComprobanteCitaUseCase(this.repository);

  Future<String> execute({
    required int citaId,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) => repository.subirComprobante(
    citaId: citaId,
    bytes: bytes,
    fileName: fileName,
    mimeType: mimeType,
  );
}
