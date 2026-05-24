import '../../domain/entities/deuda.dart';

class DeudaModel extends Deuda {
  const DeudaModel({
    required super.id,
    required super.paciente,
    required super.tratamientoAsignado,
    required super.montoOriginal,
    required super.montoPendiente,
    required super.estado,
    super.fechaLimite,
    required super.createdAt,
  });

  factory DeudaModel.fromJson(Map<String, dynamic> json) {
    return DeudaModel(
      id: json['id'],
      paciente: json['paciente'] as Map<String, dynamic>,
      tratamientoAsignado: json['tratamientoAsignado'] as Map<String, dynamic>,
      montoOriginal: (json['montoOriginal'] as num).toDouble(),
      montoPendiente: (json['montoPendiente'] as num).toDouble(),
      estado: json['estado'],
      fechaLimite: json['fechaLimite'] != null ? DateTime.parse(json['fechaLimite']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
