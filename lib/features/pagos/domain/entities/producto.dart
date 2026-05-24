import 'package:equatable/equatable.dart';

class Producto extends Equatable {
  final int id;
  final String nombre;
  final String? descripcion;
  final String unidadMedida;
  final double precioVenta;
  final int umbral;
  final bool estado;

  const Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.unidadMedida,
    required this.precioVenta,
    required this.umbral,
    required this.estado,
  });

  @override
  List<Object?> get props => [id, nombre, precioVenta];
}
