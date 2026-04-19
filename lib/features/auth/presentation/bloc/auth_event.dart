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
