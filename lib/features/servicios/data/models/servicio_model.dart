import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

class ServicioModel extends Servicio {
  const ServicioModel({
    required super.id,
    required super.nombreServicio,
    required super.tiempoMin,
    required super.estado,
  });

  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
      id: json['id'],
      nombreServicio: json['nombreServicio'],
      tiempoMin: json['tiempoMin'] ?? 30,
      estado: json['estado'] ?? true,
    );
  }
}
