import 'package:equatable/equatable.dart';

abstract class PacienteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListarPacientesEvent extends PacienteEvent {}

class ObtenerPacienteEvent extends PacienteEvent {
  final int id;
  ObtenerPacienteEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RegistrarPacienteEvent extends PacienteEvent {
  final String ci;
  final String nombre;
  final String apellido;
  final String email;
  final int? edad;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final int ciudadId;

  RegistrarPacienteEvent({
    required this.ci,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.edad,
    this.telefono,
    this.fechaNacimiento,
    required this.ciudadId,
  });

  @override
  List<Object?> get props => [
    ci,
    nombre,
    apellido,
    email,
    edad,
    telefono,
    fechaNacimiento,
    ciudadId,
  ];
}

class ModificarPacienteEvent extends PacienteEvent {
  final int id;
  final String ci;
  final int? edad;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final int ciudadId;

  ModificarPacienteEvent({
    required this.id,
    required this.ci,
    this.edad,
    this.telefono,
    this.fechaNacimiento,
    required this.ciudadId,
  });

  @override
  List<Object?> get props => [id, ci, ciudadId];
}

class CargarCiudadesEvent extends PacienteEvent {}
