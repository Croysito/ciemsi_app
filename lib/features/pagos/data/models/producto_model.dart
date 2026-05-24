import '../../domain/entities/producto.dart';

class ProductoModel extends Producto {
  const ProductoModel({
    required super.id,
    required super.nombre,
    super.descripcion,
    required super.unidadMedida,
    required super.precioVenta,
    required super.umbral,
    required super.estado,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      unidadMedida: json['unidadMedida'],
      precioVenta: (json['precioVenta'] as num).toDouble(),
      umbral: json['umbral'] ?? 0,
      estado: json['estado'] ?? true,
    );
  }
}
