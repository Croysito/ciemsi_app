import 'package:equatable/equatable.dart';
import '../../domain/entities/paciente.dart';
import '../../domain/entities/ciudad.dart';

abstract class PacienteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PacienteInitial extends PacienteState {}

class PacienteLoading extends PacienteState {}

class PacienteCompletado extends PacienteState {}

class PacientesListados extends PacienteState {
  final List<Paciente> pacientes;
  PacientesListados(this.pacientes);

  @override
  List<Object?> get props => [pacientes];
}

class PacienteObtenido extends PacienteState {
  final Paciente paciente;
  PacienteObtenido(this.paciente);

  @override
  List<Object?> get props => [paciente];
}

class PacienteRegistrado extends PacienteState {
  final String email;
  final String password;

  PacienteRegistrado({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class PacienteModificado extends PacienteState {}

class CiudadesCargadas extends PacienteState {
  final List<Ciudad> ciudades;
  CiudadesCargadas(this.ciudades);

  @override
  List<Object?> get props => [ciudades];
}

class PacienteError extends PacienteState {
  final String mensaje;
  PacienteError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
