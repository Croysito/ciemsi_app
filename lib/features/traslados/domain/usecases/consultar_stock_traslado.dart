import '../entities/traslado_stock.dart';
import '../repositories/traslado_repository.dart';

class ConsultarStockTrasladoUseCase {
  final TrasladoRepository repository;

  ConsultarStockTrasladoUseCase(this.repository);

  Future<TrasladoStock> execute({
    required String tipo,
    required int itemId,
    required int ciudadOrigenId,
  }) => repository.consultarStock(
    tipo: tipo,
    itemId: itemId,
    ciudadOrigenId: ciudadOrigenId,
  );
}
