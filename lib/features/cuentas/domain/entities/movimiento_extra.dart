class MovimientoExtra {
  final int id;
  final String tipo;
  final String categoria;
  final String? descripcion;
  final double monto;
  final String metodo;
  final int ciudadId;
  final String nombreCiudad;
  final DateTime fecha;

  const MovimientoExtra({
    required this.id,
    required this.tipo,
    required this.categoria,
    this.descripcion,
    required this.monto,
    required this.metodo,
    required this.ciudadId,
    required this.nombreCiudad,
    required this.fecha,
  });
}
