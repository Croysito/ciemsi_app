import 'package:equatable/equatable.dart';

class IngresoProductoItem extends Equatable {
  final int id;
  final Map<String, dynamic> producto; // {id, nombre, unidadMedida}
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  const IngresoProductoItem({
    required this.id,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [id];
}

class Ingreso extends Equatable {
  final int id;
  final Map<String, dynamic> paciente;
  final Map<String, dynamic> ciudad;
  final String tipo; // 'cobro_deuda' | 'venta_producto'
  final Map<String, dynamic>? deuda;
  final double monto;
  final double montoEfectivo;
  final double montoQr;
  final String metodo; // 'efectivo' | 'qr' | 'mixto'
  final String? notas;
  final List<IngresoProductoItem> items;
  final DateTime fecha;
  final DateTime createdAt;
  final Map<String, dynamic> createdBy;
  final DateTime? editadoEn;

  const Ingreso({
    required this.id,
    required this.paciente,
    required this.ciudad,
    required this.tipo,
    this.deuda,
    required this.monto,
    this.montoEfectivo = 0,
    this.montoQr = 0,
    required this.metodo,
    this.notas,
    required this.items,
    required this.fecha,
    required this.createdAt,
    required this.createdBy,
    this.editadoEn,
  });

  bool get esCobroDeuda => tipo == 'cobro_deuda';
  bool get esVentaProducto => tipo == 'venta_producto';
  bool get esMixto => metodo == 'mixto';
  bool get fueEditado => editadoEn != null;

  String get metodoLabel {
    if (esMixto) return 'Efectivo + QR';
    return metodo == 'efectivo' ? 'Efectivo' : 'QR';
  }

  @override
  List<Object?> get props => [id, monto, tipo, fecha, metodo, editadoEn];
}
