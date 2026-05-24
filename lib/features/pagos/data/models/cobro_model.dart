import '../../domain/entities/cobro.dart';

class CobroModel extends Cobro {
  const CobroModel({
    required super.id,
    required super.ingresoId,
    required super.monto,
    required super.metodo,
    required super.fecha,
    super.notas,
    required super.createdBy,
  });

  factory CobroModel.fromJson(Map<String, dynamic> json) {
    return CobroModel(
      id: json['id'],
      ingresoId: json['ingresoId'],
      monto: (json['monto'] as num).toDouble(),
      metodo: json['metodo'],
      fecha: DateTime.parse(json['fecha']),
      notas: json['notas'],
      createdBy:
          json['createdBy'] is Map<String, dynamic>
              ? json['createdBy'] as Map<String, dynamic>
              : {},
    );
  }
}
