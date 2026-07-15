import '../../domain/entities/resumen_cuenta.dart';
import '../../domain/entities/resumen_mensual_cuenta.dart';
import '../../domain/entities/historial_movimiento.dart';
import '../datasources/cuenta_remote_datasource.dart';

class CuentaRepositoryImpl {
  final CuentaRemoteDatasource _ds;
  CuentaRepositoryImpl(this._ds);

  Future<List<ResumenCuenta>> obtenerResumen({int? ciudadId}) =>
      _ds.obtenerResumen(ciudadId: ciudadId);

  Future<List<HistorialMovimiento>> obtenerHistorial({
    required int ciudadId,
    String? fechaDesde,
    String? fechaHasta,
    String? tipo,
  }) => _ds.obtenerHistorial(
        ciudadId: ciudadId,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        tipo: tipo,
      );

  Future<ResumenMensualCuenta> obtenerResumenMensual({
    required int ciudadId,
    required int anio,
    required int mes,
  }) => _ds.obtenerResumenMensual(ciudadId: ciudadId, anio: anio, mes: mes);

  Future<Map<String, double>> obtenerSaldoInicial(int ciudadId) =>
      _ds.obtenerSaldoInicial(ciudadId);

  Future<void> setSaldoInicial({
    required int ciudadId,
    required String tipo,
    required double monto,
  }) => _ds.setSaldoInicial(ciudadId: ciudadId, tipo: tipo, monto: monto);

  Future<void> registrarMovimientoExtra({
    required String tipo,
    required String categoria,
    String? descripcion,
    required double monto,
    required String metodo,
    required int ciudadId,
  }) => _ds.registrarMovimientoExtra(
        tipo: tipo,
        categoria: categoria,
        descripcion: descripcion,
        monto: monto,
        metodo: metodo,
        ciudadId: ciudadId,
      );

  Future<void> eliminarMovimientoExtra(int id) =>
      _ds.eliminarMovimientoExtra(id);

  Future<void> registrarTraspaso({
    required String tipo,
    required double monto,
    String? descripcion,
    required int ciudadId,
  }) => _ds.registrarTraspaso(
        tipo: tipo,
        monto: monto,
        descripcion: descripcion,
        ciudadId: ciudadId,
      );

  Future<void> eliminarTraspaso(int id) => _ds.eliminarTraspaso(id);
}
