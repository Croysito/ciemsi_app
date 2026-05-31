import 'package:ciemsi_app/core/network/api_client.dart';
import '../models/resumen_cuenta_model.dart';
import '../models/historial_movimiento_model.dart';

class CuentaRemoteDatasource {
  final ApiClient _client;
  CuentaRemoteDatasource(this._client);

  Future<List<ResumenCuentaModel>> obtenerResumen({int? ciudadId}) async {
    final params = ciudadId != null ? {'ciudadId': ciudadId} : null;
    final res = await _client.dio.get('/cuentas/resumen', queryParameters: params);
    return (res.data as List).map((e) => ResumenCuentaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<HistorialMovimientoModel>> obtenerHistorial({
    required int ciudadId,
    String? fechaDesde,
    String? fechaHasta,
    String? tipo,
  }) async {
    final res = await _client.dio.get('/cuentas/historial', queryParameters: {
      'ciudadId': ciudadId,
      'fechaDesde': ?fechaDesde,
      'fechaHasta': ?fechaHasta,
      'tipo': ?tipo,
    });
    return (res.data as List).map((e) => HistorialMovimientoModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, double>> obtenerSaldoInicial(int ciudadId) async {
    final res = await _client.dio.get('/cuentas/saldo-inicial/$ciudadId');
    final data = res.data as Map<String, dynamic>;
    return {
      'caja':  (data['caja']  as num?)?.toDouble() ?? 0.0,
      'banco': (data['banco'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<void> setSaldoInicial({required int ciudadId, required String tipo, required double monto}) async {
    await _client.dio.put('/cuentas/saldo-inicial/$ciudadId', data: {'tipo': tipo, 'monto': monto});
  }

  Future<void> registrarMovimientoExtra({
    required String tipo,
    required String categoria,
    String? descripcion,
    required double monto,
    required String metodo,
    required int ciudadId,
  }) async {
    await _client.dio.post('/cuentas/movimientos', data: {
      'tipo': tipo,
      'categoria': categoria,
      'descripcion': ?descripcion,
      'monto': monto,
      'metodo': metodo,
      'ciudadId': ciudadId,
    });
  }

  Future<void> eliminarMovimientoExtra(int id) async {
    await _client.dio.delete('/cuentas/movimientos/$id');
  }

  Future<void> registrarTraspaso({
    required String tipo,
    required double monto,
    String? descripcion,
    required int ciudadId,
  }) async {
    await _client.dio.post('/cuentas/traspasos', data: {
      'tipo': tipo,
      'monto': monto,
      'descripcion': ?descripcion,
      'ciudadId': ciudadId,
    });
  }

  Future<void> eliminarTraspaso(int id) async {
    await _client.dio.delete('/cuentas/traspasos/$id');
  }
}
