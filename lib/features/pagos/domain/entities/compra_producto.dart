import 'package:equatable/equatable.dart';

class CompraProductoItem extends Equatable {
  final int id;
  final Map<String, dynamic> producto; // {id, nombre, unidadMedida}
  final double cantidad;
  final double precioUnitario;

  double get subtotal => cantidad * precioUnitario;

  const CompraProductoItem({
    required this.id,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
  });

  @override
  List<Object?> get props => [id];
}

class CompraProducto extends Equatable {
  final int id;
  final Map<String, dynamic> ciudad;
  final DateTime fecha;
  final String? proveedor;
  final String? notas;
  final List<CompraProductoItem> items;
  final Map<String, dynamic> createdBy;
  final DateTime createdAt;

  double get total => items.fold(0, (sum, i) => sum + i.subtotal);

  const CompraProducto({
    required this.id,
    required this.ciudad,
    required this.fecha,
    this.proveedor,
    this.notas,
    required this.items,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, fecha, total];
}
