import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class Usuario extends Equatable {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;
  final Ciudad? ciudad;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.ciudad,
  });

  String get nombreCompleto => '$nombre $apellido';

  @override
  List<Object?> get props => [id, nombre, apellido, email, rol, ciudad];
}
