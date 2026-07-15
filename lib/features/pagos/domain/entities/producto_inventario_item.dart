import 'package:equatable/equatable.dart';

class ProductoInventarioItem extends Equatable {
  final int id;
  final String nombre;
  final String unidadMedida;
  final double saldo;
  final int umbral;
  final double totalCompras;
  final double totalVentas;
  final bool stockBajo;

  const ProductoInventarioItem({
    required this.id,
    required this.nombre,
    required this.unidadMedida,
    required this.saldo,
    required this.umbral,
    required this.totalCompras,
    required this.totalVentas,
    required this.stockBajo,
  });

  @override
  List<Object?> get props => [
    id,
    nombre,
    unidadMedida,
    saldo,
    umbral,
    totalCompras,
    totalVentas,
    stockBajo,
  ];
}
