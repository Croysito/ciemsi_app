import '../entities/link_archivo.dart';
import '../repositories/historial_repository.dart';

class AgregarLinkUseCase {
  final HistorialRepository repository;
  AgregarLinkUseCase(this.repository);

  Future<LinkArchivo> execute({
    required int notaId,
    required String nombre,
    required String link,
    required String tipo,
  }) => repository.agregarLink(
    notaId: notaId,
    nombre: nombre,
    link: link,
    tipo: tipo,
  );
}
