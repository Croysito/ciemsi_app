import 'package:equatable/equatable.dart';

class Usuario extends Equatable {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
  });

  String get nombreCompleto => '$nombre $apellido';

  @override
  List<Object> get props => [id, nombre, apellido, email, rol];
}
