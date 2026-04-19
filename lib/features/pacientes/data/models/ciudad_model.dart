import '../../domain/entities/ciudad.dart';

class CiudadModel extends Ciudad {
  const CiudadModel({required super.id, required super.nombreCiudad});

  factory CiudadModel.fromJson(Map<String, dynamic> json) {
    return CiudadModel(id: json['id'], nombreCiudad: json['nombreCiudad']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombreCiudad': nombreCiudad};
}
