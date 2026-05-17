import 'package:equatable/equatable.dart';

class RegistroPacienteResult extends Equatable {
  final String email;
  final String password;

  const RegistroPacienteResult({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
