import '../../domain/entities/resumen_cuenta.dart';

class ResumenCuentaModel extends ResumenCuenta {
  const ResumenCuentaModel({
    required super.ciudadId,
    required super.nombreCiudad,
    required super.saldoInicialCaja,
    required super.saldoInicialBanco,
    required super.ingresosCaja,
    required super.ingresosBanco,
    required super.egresosCaja,
    required super.egresosBanco,
    required super.saldoCaja,
    required super.saldoBanco,
  });

  factory ResumenCuentaModel.fromJson(Map<String, dynamic> j) {
    final ciudad = j['ciudad'] as Map<String, dynamic>? ?? {};
    return ResumenCuentaModel(
      ciudadId:         _i(ciudad['id']),
      nombreCiudad:     ciudad['nombreCiudad']?.toString() ?? '',
      saldoInicialCaja:  _d(j['saldoInicialCaja']),
      saldoInicialBanco: _d(j['saldoInicialBanco']),
      ingresosCaja:  _d(j['ingresosCaja']),
      ingresosBanco: _d(j['ingresosBanco']),
      egresosCaja:   _d(j['egresosCaja']),
      egresosBanco:  _d(j['egresosBanco']),
      saldoCaja:     _d(j['saldoCaja']),
      saldoBanco:    _d(j['saldoBanco']),
    );
  }

  static double _d(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
  static int    _i(dynamic v) => v == null ? 0   : (v is int ? v : int.tryParse(v.toString()) ?? 0);
}
