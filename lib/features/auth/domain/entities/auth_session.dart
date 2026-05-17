import 'package:equatable/equatable.dart';

import 'usuario.dart';

class AuthSession extends Equatable {
  final Usuario usuario;
  final String token;

  const AuthSession({required this.usuario, required this.token});

  @override
  List<Object?> get props => [usuario, token];
}
