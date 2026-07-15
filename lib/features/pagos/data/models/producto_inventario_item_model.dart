import '../../domain/entities/producto_inventario_item.dart';

class ProductoInventarioItemModel extends ProductoInventarioItem {
  const ProductoInventarioItemModel({
    required super.id,
    required super.nombre,
    required super.unidadMedida,
    required super.saldo,
    required super.umbral,
    required super.totalCompras,
    required super.totalVentas,
    required super.stockBajo,
  });

  factory ProductoInventarioItemModel.fromJson(Map<String, dynamic> json) {
    return ProductoInventarioItemModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      unidadMedida: json['unidad_medida']?.toString() ?? '',
      saldo: double.tryParse(json['saldo'].toString()) ?? 0,
      umbral: int.tryParse(json['umbral'].toString()) ?? 0,
      totalCompras: double.tryParse(json['total_compras'].toString()) ?? 0,
      totalVentas: double.tryParse(json['total_ventas'].toString()) ?? 0,
      stockBajo: json['stock_bajo'] == true,
    );
  }
}
