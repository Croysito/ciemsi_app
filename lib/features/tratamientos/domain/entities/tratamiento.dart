import 'package:equatable/equatable.dart';

class Tratamiento extends Equatable {
  final int id;
  final String nombreTratamiento;
  final String? detalle;
  final double precioBase;

  const Tratamiento({
    required this.id,
    required this.nombreTratamiento,
    this.detalle,
    required this.precioBase,
  });

  @override
  List<Object?> get props => [id, nombreTratamiento, detalle, precioBase];
}
