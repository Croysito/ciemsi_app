import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class Usuario extends Equatable {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;
  final Ciudad? ciudad;
  final Map<String, bool> permisos;
  // Asistente puntual habilitado para ver/operar en todas las ciudades,
  // igual que la Doctora, sin dejar de tener una ciudad propia asignada.
  final bool veTodasCiudades;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.ciudad,
    this.permisos = const {},
    this.veTodasCiudades = false,
  });

  String get nombreCompleto => '$nombre $apellido';

  @override
  List<Object?> get props => [
    id,
    nombre,
    apellido,
    email,
    rol,
    ciudad,
    permisos,
    veTodasCiudades,
  ];
}
