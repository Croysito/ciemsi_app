import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/agenda/data/models/agenda_model.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

abstract class AgendaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AgendaInitial extends AgendaState {}

class AgendaLoading extends AgendaState {}

class AgendasCargadas extends AgendaState {
  final List<AgendaModel> agendas;

  AgendasCargadas(this.agendas);

  @override
  List<Object?> get props => [agendas];
}

class CiudadesAgendaCargadas extends AgendaState {
  final List<Ciudad> ciudades;

  CiudadesAgendaCargadas(this.ciudades);

  @override
  List<Object?> get props => [ciudades];
}

class AgendaOperacionExitosa extends AgendaState {}

class AgendaError extends AgendaState {
  final String mensaje;

  AgendaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
