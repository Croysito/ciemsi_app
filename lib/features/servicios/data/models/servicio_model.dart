import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

class ServicioModel extends Servicio {
  const ServicioModel({
    required super.id,
    required super.nombreServicio,
    required super.tiempoMin,
    required super.estado,
    super.roles = const [],
  });

  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
      id: json['id'],
      nombreServicio: json['nombreServicio'],
      tiempoMin: json['tiempoMin'] ?? 30,
      estado: json['estado'] ?? true,
      roles: (json['roles'] as List?)?.map((r) => r.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'nombreServicio': nombreServicio,
    'tiempoMin': tiempoMin,
    'estado': estado,
    'roles': roles,
  };
}
