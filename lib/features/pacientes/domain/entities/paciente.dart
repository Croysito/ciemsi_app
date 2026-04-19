import 'package:equatable/equatable.dart';
import 'ciudad.dart';

class Paciente extends Equatable {
  final int id;
  final String ci;
  final String nombre;
  final int? edad;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final Ciudad ciudad;

  const Paciente({
    required this.id,
    required this.ci,
    required this.nombre,
    this.edad,
    this.telefono,
    this.fechaNacimiento,
    required this.ciudad,
  });

  @override
  List<Object?> get props => [
    id,
    ci,
    nombre,
    edad,
    telefono,
    fechaNacimiento,
    ciudad,
  ];
}
