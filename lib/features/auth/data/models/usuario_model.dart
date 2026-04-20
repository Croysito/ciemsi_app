import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.email,
    required super.rol,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    // El rol puede venir como String o como objeto
    String rolNombre = '';
    if (json['rol'] is String) {
      rolNombre = json['rol'];
    } else if (json['rol'] is Map) {
      rolNombre = json['rol']['nombreRol'] ?? '';
    }

    return UsuarioModel(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'] ?? '',
      email: json['email'],
      rol: rolNombre,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'email': email,
    'rol': rol,
  };
}
