class ResumenMensualCuenta {
  final int ciudadId;
  final String nombreCiudad;
  final int anio;
  final int mes;
  final double saldoInicialCaja;
  final double saldoInicialBanco;
  final double ingresosCajaMes;
  final double ingresosBancoMes;
  final double egresosCajaMes;
  final double egresosBancoMes;
  final double saldoFinalCaja;
  final double saldoFinalBanco;

  const ResumenMensualCuenta({
    required this.ciudadId,
    required this.nombreCiudad,
    required this.anio,
    required this.mes,
    required this.saldoInicialCaja,
    required this.saldoInicialBanco,
    required this.ingresosCajaMes,
    required this.ingresosBancoMes,
    required this.egresosCajaMes,
    required this.egresosBancoMes,
    required this.saldoFinalCaja,
    required this.saldoFinalBanco,
  });
}
