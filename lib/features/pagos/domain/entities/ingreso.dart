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
  final String metodo;
  final String? notas;
  final List<IngresoProductoItem> items;
  final DateTime fecha;
  final DateTime createdAt;
  final Map<String, dynamic> createdBy;

  const Ingreso({
    required this.id,
    required this.paciente,
    required this.ciudad,
    required this.tipo,
    this.deuda,
    required this.monto,
    required this.metodo,
    this.notas,
    required this.items,
    required this.fecha,
    required this.createdAt,
    required this.createdBy,
  });

  bool get esCobroDeuda => tipo == 'cobro_deuda';
  bool get esVentaProducto => tipo == 'venta_producto';

  @override
  List<Object?> get props => [id, monto, tipo, fecha];
}
