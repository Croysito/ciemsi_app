// lib/features/suministros/data/models/inventario_model.dart
import 'package:ciemsi_app/features/suministros/domain/entities/inventario_item.dart';

class InventarioModel extends InventarioItem {
  const InventarioModel({
    required super.id,
    required super.nombreSuministro,
    required super.unidadMedida,
    super.marca,
    required super.tipo,
    required super.umbral,
    required super.ciudadId,
    required super.nombreCiudad,
    required super.totalCompras,
    required super.totalSalidas,
    required super.saldo,
    required super.stockBajo,
  });

  factory InventarioModel.fromJson(Map<String, dynamic> json) {
    return InventarioModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombreSuministro: json['nombre_suministro'],
      unidadMedida: json['unidad_medida'],
      marca: json['marca'],
      tipo: json['tipo'],
      umbral: int.tryParse(json['umbral'].toString()) ?? 5,
      ciudadId: int.tryParse(json['ciudad_id'].toString()) ?? 0,
      nombreCiudad: json['nombre_ciudad'],
      totalCompras: double.tryParse(json['total_compras'].toString()) ?? 0,
      totalSalidas: double.tryParse(json['total_salidas'].toString()) ?? 0,
      saldo: double.tryParse(json['saldo'].toString()) ?? 0,
      stockBajo: json['stock_bajo'] ?? false,
    );
  }
}
