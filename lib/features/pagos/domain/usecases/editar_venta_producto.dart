import '../entities/ingreso.dart';
import '../repositories/pago_repository.dart';

class EditarVentaProductoUseCase {
  final PagoRepository repository;
  EditarVentaProductoUseCase(this.repository);

  Future<Ingreso> execute({
    required int id,
    required List<Map<String, dynamic>> items,
    required double montoEfectivo,
    required double montoQr,
    String? notas,
  }) => repository.editarVentaProducto(
        id: id,
        items: items,
        montoEfectivo: montoEfectivo,
        montoQr: montoQr,
        notas: notas,
      );
}
