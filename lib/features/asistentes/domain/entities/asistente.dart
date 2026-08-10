import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class Asistente extends Equatable {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final bool estado;
  final Ciudad? ciudad;
  // Habilita a este asistente puntual a ver/operar en todas las ciudades,
  // igual que la Doctora, sin dejar de tener una ciudad propia asignada.
  final bool veTodasCiudades;

  const Asistente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.estado,
    this.ciudad,
    this.veTodasCiudades = false,
  });

  String get nombreCompleto => '$nombre $apellido';

  @override
  List<Object?> get props => [
    id,
    nombre,
    apellido,
    email,
    estado,
    ciudad,
    veTodasCiudades,
  ];
}
