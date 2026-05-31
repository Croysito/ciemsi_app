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
  final String? telefono;
  final DateTime? fechaNacimiento;
  final String? genero;
  final int ciudadId;

  RegistrarPacienteEvent({
    required this.ci,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.fechaNacimiento,
    this.genero,
    required this.ciudadId,
  });

  @override
  List<Object?> get props => [
    ci,
    nombre,
    apellido,
    email,
    telefono,
    fechaNacimiento,
    genero,
    ciudadId,
  ];
}

class ModificarPacienteEvent extends PacienteEvent {
  final int id;
  final String ci;
  final String? nombre;
  final String? apellido;
  final String? email;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final String? genero;
  final int ciudadId;

  ModificarPacienteEvent({
    required this.id,
    required this.ci,
    this.nombre,
    this.apellido,
    this.email,
    this.telefono,
    this.fechaNacimiento,
    this.genero,
    required this.ciudadId,
  });

  @override
  List<Object?> get props => [id, ci, nombre, apellido, email, genero, ciudadId];
}
class CompletarPacienteEvent extends PacienteEvent {
  final int id;
  final String ci;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final String? genero;
  final int ciudadId;

  CompletarPacienteEvent({
    required this.id,
    required this.ci,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.fechaNacimiento,
    this.genero,
    required this.ciudadId,
  });

  @override
  List<Object?> get props => [id, ci, nombre, apellido, email, genero, ciudadId];
}

class CargarCiudadesEvent extends PacienteEvent {}
