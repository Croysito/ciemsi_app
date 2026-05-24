import 'package:equatable/equatable.dart';

abstract class AgendaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CargarAgendasEvent extends AgendaEvent {}

class CambiarEstadoAgendaEvent extends AgendaEvent {
  final int id;
  final bool estado;

  CambiarEstadoAgendaEvent(this.id, this.estado);

  @override
  List<Object?> get props => [id, estado];
}

class EliminarAgendaEvent extends AgendaEvent {
  final int id;

  EliminarAgendaEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CargarCiudadesAgendaEvent extends AgendaEvent {}

class CrearAgendaEvent extends AgendaEvent {
  final Map<String, dynamic> datos;

  CrearAgendaEvent(this.datos);

  @override
  List<Object?> get props => [datos];
}
