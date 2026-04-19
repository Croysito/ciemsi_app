import '../../domain/entities/nota_evolucion.dart';
import 'link_model.dart';

class NotaModel extends NotaEvolucion {
  const NotaModel({
    required super.id,
    required super.fecha,
    required super.detalle,
    required super.historialId,
    super.links,
  });

  factory NotaModel.fromJson(Map<String, dynamic> json) {
    return NotaModel(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      detalle: json['detalle'],
      historialId: json['historialId'] ?? json['historial_id'],
      links:
          (json['links'] as List<dynamic>?)
              ?.map((l) => LinkModel.fromJson(l))
              .toList() ??
          [],
    );
  }
}
