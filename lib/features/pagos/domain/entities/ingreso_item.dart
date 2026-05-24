import 'package:equatable/equatable.dart';

class IngresoItem extends Equatable {
  final int id;
  final int ingresoId;
  final String tipo;
  final int? referenciaId;
  final String descripcion;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  const IngresoItem({
    required this.id,
    required this.ingresoId,
    required this.tipo,
    this.referenciaId,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [id, ingresoId, tipo, descripcion, cantidad, precioUnitario];
}
