import 'package:equatable/equatable.dart';

class Cobro extends Equatable {
  final int id;
  final int ingresoId;
  final double monto;
  final String metodo;
  final DateTime fecha;
  final String? notas;
  final Map<String, dynamic> createdBy;

  const Cobro({
    required this.id,
    required this.ingresoId,
    required this.monto,
    required this.metodo,
    required this.fecha,
    this.notas,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [id, ingresoId, monto, metodo, fecha];
}
