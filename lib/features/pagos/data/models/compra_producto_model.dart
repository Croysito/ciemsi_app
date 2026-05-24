import '../../domain/entities/compra_producto.dart';

class CompraProductoItemModel extends CompraProductoItem {
  const CompraProductoItemModel({
    required super.id,
    required super.producto,
    required super.cantidad,
    required super.precioUnitario,
  });

  factory CompraProductoItemModel.fromJson(Map<String, dynamic> json) {
    return CompraProductoItemModel(
      id: json['id'],
      producto: json['producto'] as Map<String, dynamic>,
      cantidad: (json['cantidad'] as num).toDouble(),
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
    );
  }
}

class CompraProductoModel extends CompraProducto {
  const CompraProductoModel({
    required super.id,
    required super.ciudad,
    required super.fecha,
    super.proveedor,
    super.notas,
    required super.items,
    required super.createdBy,
    required super.createdAt,
  });

  factory CompraProductoModel.fromJson(Map<String, dynamic> json) {
    return CompraProductoModel(
      id: json['id'],
      ciudad: json['ciudad'] as Map<String, dynamic>,
      fecha: DateTime.parse(json['fecha']),
      proveedor: json['proveedor'],
      notas: json['notas'],
      items: (json['items'] as List? ?? [])
          .map((i) => CompraProductoItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      createdBy: json['createdBy'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
