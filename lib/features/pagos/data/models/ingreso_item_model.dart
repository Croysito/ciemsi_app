import '../../domain/entities/ingreso_item.dart';

class IngresoItemModel extends IngresoItem {
  const IngresoItemModel({
    required super.id,
    required super.ingresoId,
    required super.tipo,
    super.referenciaId,
    required super.descripcion,
    required super.cantidad,
    required super.precioUnitario,
    required super.subtotal,
  });

  factory IngresoItemModel.fromJson(Map<String, dynamic> json) {
    return IngresoItemModel(
      id: json['id'],
      ingresoId: json['ingresoId'],
      tipo: json['tipo'],
      referenciaId: json['referenciaId'],
      descripcion: json['descripcion'],
      cantidad: (json['cantidad'] as num).toDouble(),
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}
