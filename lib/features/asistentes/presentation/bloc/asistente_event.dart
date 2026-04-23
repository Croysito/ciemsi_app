import 'package:equatable/equatable.dart';

abstract class AsistenteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListarAsistentesEvent extends AsistenteEvent {}

class CrearAsistenteEvent extends AsistenteEvent {
  final String nombre;
  final String apellido;
  final String email;
  final String ci;
  final int ciudadId;

  CrearAsistenteEvent({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.ci,
    required this.ciudadId,
  });

  @override
  List<Object?> get props => [nombre, apellido, email, ci, ciudadId];
}

class ModificarAsistenteEvent extends AsistenteEvent {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final int ciudadId;

  ModificarAsistenteEvent({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.ciudadId,
  });

  @override
  List<Object?> get props => [id, nombre, apellido, email, ciudadId];
}

class CambiarEstadoAsistenteEvent extends AsistenteEvent {
  final int id;
  final bool estado;

  CambiarEstadoAsistenteEvent({required this.id, required this.estado});

  @override
  List<Object?> get props => [id, estado];
}

class CambiarPasswordEvent extends AsistenteEvent {
  final String passwordActual;
  final String passwordNuevo;

  CambiarPasswordEvent({
    required this.passwordActual,
    required this.passwordNuevo,
  });

  @override
  List<Object?> get props => [passwordActual, passwordNuevo];
}
