import 'dart:typed_data';
import '../repositories/cita_repository.dart';

class SubirQrPagoImagenUseCase {
  final CitaRepository repository;
  SubirQrPagoImagenUseCase(this.repository);

  Future<String> execute({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required String tokens,
  }) => repository.subirQrPagoImagen(
    bytes: bytes,
    fileName: fileName,
    mimeType: mimeType,
    tokens: tokens,
  );
}
