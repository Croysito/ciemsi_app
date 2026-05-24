import 'package:equatable/equatable.dart';
import '../../domain/entities/usuario.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Usuario usuario;
  final String token;

  AuthSuccess({required this.usuario, required this.token});

  @override
  List<Object> get props => [usuario, token];
}

class AuthError extends AuthState {
  final String mensaje;

  AuthError({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}

class RecuperarContrasenaSuccess extends AuthState {}

class CerrarSesionSuccess extends AuthState {}

class SesionVerificada extends AuthState {
  final Usuario usuario;
  SesionVerificada({required this.usuario});

  @override
  List<Object> get props => [usuario];
}

class SesionInvalida extends AuthState {}
