import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/asistentes/domain/entities/asistente.dart';

abstract class AsistenteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AsistenteInitial extends AsistenteState {}

class AsistenteLoading extends AsistenteState {}

class AsistentesListados extends AsistenteState {
  final List<Asistente> asistentes;
  AsistentesListados(this.asistentes);

  @override
  List<Object?> get props => [asistentes];
}

class AsistenteCreado extends AsistenteState {
  final String email;
  final String password;
  AsistenteCreado({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AsistenteModificado extends AsistenteState {}

class EstadoCambiado extends AsistenteState {}

class PasswordCambiado extends AsistenteState {}

class AsistenteError extends AsistenteState {
  final String mensaje;
  AsistenteError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
