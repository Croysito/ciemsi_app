import '../../domain/entities/resumen_mensual_cuenta.dart';

class ResumenMensualCuentaModel extends ResumenMensualCuenta {
  const ResumenMensualCuentaModel({
    required super.ciudadId,
    required super.nombreCiudad,
    required super.anio,
    required super.mes,
    required super.saldoInicialCaja,
    required super.saldoInicialBanco,
    required super.ingresosCajaMes,
    required super.ingresosBancoMes,
    required super.egresosCajaMes,
    required super.egresosBancoMes,
    required super.saldoFinalCaja,
    required super.saldoFinalBanco,
  });

  factory ResumenMensualCuentaModel.fromJson(Map<String, dynamic> j) {
    final ciudad = j['ciudad'] as Map<String, dynamic>? ?? {};
    return ResumenMensualCuentaModel(
      ciudadId:     _i(ciudad['id']),
      nombreCiudad: ciudad['nombreCiudad']?.toString() ?? '',
      anio: _i(j['anio']),
      mes:  _i(j['mes']),
      saldoInicialCaja:  _d(j['saldoInicialCaja']),
      saldoInicialBanco: _d(j['saldoInicialBanco']),
      ingresosCajaMes:  _d(j['ingresosCajaMes']),
      ingresosBancoMes: _d(j['ingresosBancoMes']),
      egresosCajaMes:   _d(j['egresosCajaMes']),
      egresosBancoMes:  _d(j['egresosBancoMes']),
      saldoFinalCaja:   _d(j['saldoFinalCaja']),
      saldoFinalBanco:  _d(j['saldoFinalBanco']),
    );
  }

  static double _d(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
  static int    _i(dynamic v) => v == null ? 0   : (v is int ? v : int.tryParse(v.toString()) ?? 0);
}
