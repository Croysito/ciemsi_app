class HistorialMovimiento {
  final int id;
  final String tipo;        // 'ingreso' | 'egreso'
  final String categoria;
  final String? descripcion;
  final double monto;
  final String metodo;      // 'efectivo' | 'qr' | 'transferencia'
  final DateTime fecha;
  final String fuente;      // 'ingreso_paciente' | 'compra' | 'movimiento_extra' | 'traslado'

  const HistorialMovimiento({
    required this.id,
    required this.tipo,
    required this.categoria,
    this.descripcion,
    required this.monto,
    required this.metodo,
    required this.fecha,
    required this.fuente,
  });

  bool get esIngreso => tipo == 'ingreso';
  bool get esEfectivo => metodo == 'efectivo';
}
