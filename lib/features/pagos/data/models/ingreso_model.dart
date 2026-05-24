import '../../domain/entities/ingreso.dart';

class IngresoProductoItemModel extends IngresoProductoItem {
  const IngresoProductoItemModel({
    required super.id,
    required super.producto,
    required super.cantidad,
    required super.precioUnitario,
    required super.subtotal,
  });

  factory IngresoProductoItemModel.fromJson(Map<String, dynamic> json) {
    return IngresoProductoItemModel(
      id: json['id'],
      producto: json['producto'] as Map<String, dynamic>,
      cantidad: (json['cantidad'] as num).toDouble(),
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class IngresoModel extends Ingreso {
  const IngresoModel({
    required super.id,
    required super.paciente,
    required super.ciudad,
    required super.tipo,
    super.deuda,
    required super.monto,
    required super.metodo,
    super.notas,
    required super.items,
    required super.fecha,
    required super.createdAt,
    required super.createdBy,
  });

  factory IngresoModel.fromJson(Map<String, dynamic> json) {
    return IngresoModel(
      id: json['id'],
      paciente: json['paciente'] as Map<String, dynamic>,
      ciudad: json['ciudad'] as Map<String, dynamic>,
      tipo: json['tipo'],
      deuda: json['deuda'] as Map<String, dynamic>?,
      monto: (json['monto'] as num).toDouble(),
      metodo: json['metodo'],
      notas: json['notas'],
      items: (json['items'] as List? ?? [])
          .map((i) => IngresoProductoItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      fecha: DateTime.parse(json['fecha']),
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'] as Map<String, dynamic>,
    );
  }
}
