import '../repositories/traslado_repository.dart';

class CrearTrasladoUseCase {
  final TrasladoRepository repository;
  CrearTrasladoUseCase(this.repository);

  Future<void> execute({
    required String tipo,
    int? suministroId,
    int? productoId,
    required int ciudadOrigenId,
    required int ciudadDestinoId,
    required double cantidad,
  }) =>
      repository.crear(
        tipo: tipo,
        suministroId: suministroId,
        productoId: productoId,
        ciudadOrigenId: ciudadOrigenId,
        ciudadDestinoId: ciudadDestinoId,
        cantidad: cantidad,
      );
}
