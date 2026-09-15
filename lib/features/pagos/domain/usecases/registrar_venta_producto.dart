import '../entities/ingreso.dart';
import '../repositories/pago_repository.dart';

class RegistrarVentaProductoUseCase {
  final PagoRepository repository;
  RegistrarVentaProductoUseCase(this.repository);

  Future<Ingreso> execute({
    required int pacienteId,
    required int ciudadId,
    required List<Map<String, dynamic>> items,
    required double montoEfectivo,
    required double montoQr,
    String? notas,
  }) => repository.registrarVentaProducto(
        pacienteId: pacienteId,
        ciudadId: ciudadId,
        items: items,
        montoEfectivo: montoEfectivo,
        montoQr: montoQr,
        notas: notas,
      );
}
