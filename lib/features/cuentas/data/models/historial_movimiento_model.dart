import '../../domain/entities/historial_movimiento.dart';

class HistorialMovimientoModel extends HistorialMovimiento {
  const HistorialMovimientoModel({
    required super.id,
    required super.tipo,
    required super.categoria,
    super.descripcion,
    required super.monto,
    required super.metodo,
    required super.fecha,
    required super.fuente,
  });

  factory HistorialMovimientoModel.fromJson(Map<String, dynamic> j) {
    return HistorialMovimientoModel(
      id:          _i(j['id']),
      tipo:        j['tipo_mov']?.toString() ?? j['tipo']?.toString() ?? '',
      categoria:   j['categoria']?.toString() ?? '',
      descripcion: j['descripcion']?.toString(),
      monto:       _d(j['monto']),
      metodo:      j['metodo']?.toString() ?? 'efectivo',
      fecha:       DateTime.tryParse(j['fecha']?.toString() ?? '') ?? DateTime.now(),
      fuente:      j['fuente']?.toString() ?? '',
    );
  }

  static double _d(dynamic v) => v == null ? 0.0 : (v as num).toDouble();
  static int    _i(dynamic v) => v == null ? 0   : (v is int ? v : int.tryParse(v.toString()) ?? 0);
}
