import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';
import 'package:ciemsi_app/features/pacientes/data/models/ciudad_model.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.email,
    required super.rol,
    super.ciudad,
    super.permisos,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    String rolNombre = '';
    if (json['rol'] is String) {
      rolNombre = json['rol'];
    } else if (json['rol'] is Map) {
      rolNombre = json['rol']['nombreRol'] ?? '';
    }

    Ciudad? ciudad;
    if (json['ciudad'] != null && json['ciudad'] is Map) {
      ciudad = CiudadModel.fromJson(json['ciudad']);
    }

    Map<String, bool> permisos = const {};
    if (json['permisos'] is Map) {
      permisos = (json['permisos'] as Map).map(
        (key, value) => MapEntry(key.toString(), value == true),
      );
    }

    return UsuarioModel(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'] ?? '',
      email: json['email'],
      rol: rolNombre,
      ciudad: ciudad,
      permisos: permisos,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'email': email,
    'rol': rol,
    'ciudad': ciudad != null
        ? {'id': ciudad!.id, 'nombreCiudad': ciudad!.nombreCiudad}
        : null,
    'permisos': permisos,
  };
}
