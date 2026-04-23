import 'package:ciemsi_app/features/asistentes/domain/entities/asistente.dart';
import 'package:ciemsi_app/features/pacientes/data/models/ciudad_model.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class AsistenteModel extends Asistente {
  const AsistenteModel({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.email,
    required super.estado,
    super.ciudad,
  });

  factory AsistenteModel.fromJson(Map<String, dynamic> json) {
    Ciudad? ciudad;
    if (json['ciudad'] != null && json['ciudad'] is Map) {
      ciudad = CiudadModel.fromJson(json['ciudad']);
    }

    return AsistenteModel(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'] ?? '',
      email: json['email'],
      estado: json['estado'] ?? true,
      ciudad: ciudad,
    );
  }
}
