import 'package:equatable/equatable.dart';
import 'medicamento_base.dart';

class Tratamiento extends Equatable {
  final int id;
  final String nombreTratamiento;
  final String? detalle;
  final double precioBase;
  final List<MedicamentoBase> medicamentosBase;

  const Tratamiento({
    required this.id,
    required this.nombreTratamiento,
    this.detalle,
    required this.precioBase,
    this.medicamentosBase = const [],
  });

  @override
  List<Object?> get props => [
    id,
    nombreTratamiento,
    detalle,
    precioBase,
    medicamentosBase,
  ];
}
