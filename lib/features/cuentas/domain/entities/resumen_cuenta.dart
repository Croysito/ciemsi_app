class ResumenCuenta {
  final int ciudadId;
  final String nombreCiudad;
  final double saldoInicialCaja;
  final double saldoInicialBanco;
  final double ingresosCaja;
  final double ingresosBanco;
  final double egresosCaja;
  final double egresosBanco;
  final double saldoCaja;
  final double saldoBanco;

  const ResumenCuenta({
    required this.ciudadId,
    required this.nombreCiudad,
    required this.saldoInicialCaja,
    required this.saldoInicialBanco,
    required this.ingresosCaja,
    required this.ingresosBanco,
    required this.egresosCaja,
    required this.egresosBanco,
    required this.saldoCaja,
    required this.saldoBanco,
  });
}
