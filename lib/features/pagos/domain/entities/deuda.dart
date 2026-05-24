import 'package:equatable/equatable.dart';

class Deuda extends Equatable {
  final int id;
  final Map<String, dynamic> paciente;
  final Map<String, dynamic> tratamientoAsignado; // {id, nombre, precio}
  final double montoOriginal;
  final double montoPendiente;
  final String estado;
  final DateTime? fechaLimite;
  final DateTime createdAt;

  const Deuda({
    required this.id,
    required this.paciente,
    required this.tratamientoAsignado,
    required this.montoOriginal,
    required this.montoPendiente,
    required this.estado,
    this.fechaLimite,
    required this.createdAt,
  });

  bool get estaPendiente => estado == 'pendiente';
  bool get estaPagada => estado == 'pagada';
  double get montoCobrado => montoOriginal - montoPendiente;
  String get nombreTratamiento => tratamientoAsignado['nombre'] ?? '';

  @override
  List<Object?> get props => [id, montoPendiente, estado];
}
