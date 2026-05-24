import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RecuperarContrasenaEvent extends AuthEvent {
  final String email;

  RecuperarContrasenaEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class CerrarSesionEvent extends AuthEvent {}

class VerificarTokenEvent extends AuthEvent {
  final String token;
  final Map<String, dynamic> usuarioData;

  VerificarTokenEvent({required this.token, required this.usuarioData});

  @override
  List<Object> get props => [token];
}
