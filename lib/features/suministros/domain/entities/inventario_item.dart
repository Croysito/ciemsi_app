import 'package:equatable/equatable.dart';

class InventarioItem extends Equatable {
  final int id;
  final String nombreSuministro;
  final String unidadMedida;
  final String? marca;
  final String tipo;
  final int umbral;
  final int ciudadId;
  final String nombreCiudad;
  final double totalCompras;
  final double totalSalidas;
  final double saldo;
  final bool stockBajo;

  const InventarioItem({
    required this.id,
    required this.nombreSuministro,
    required this.unidadMedida,
    this.marca,
    required this.tipo,
    required this.umbral,
    required this.ciudadId,
    required this.nombreCiudad,
    required this.totalCompras,
    required this.totalSalidas,
    required this.saldo,
    required this.stockBajo,
  });

  @override
  List<Object?> get props => [id, nombreSuministro, saldo, stockBajo];
}
