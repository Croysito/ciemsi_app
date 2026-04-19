import '../../domain/entities/historial_clinico.dart';
import 'nota_model.dart';

class HistorialModel extends HistorialClinico {
  const HistorialModel({
    required super.id,
    required super.fecha,
    required super.pacienteId,
    super.notas,
  });

  factory HistorialModel.fromJson(Map<String, dynamic> json) {
    return HistorialModel(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      pacienteId: json['pacienteId'] ?? json['paciente_id'],
      notas:
          (json['notas'] as List<dynamic>?)
              ?.map((n) => NotaModel.fromJson(n))
              .toList() ??
          [],
    );
  }
}
