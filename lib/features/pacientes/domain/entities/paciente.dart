import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';

class Paciente extends Equatable {
  final int id;
  final String ci;
  final int? edad;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final Usuario usuario;

  const Paciente({
    required this.id,
    required this.ci,
    this.edad,
    this.telefono,
    this.fechaNacimiento,
    required this.usuario,
  });

  String get nombreCompleto => usuario.nombreCompleto;
  Ciudad? get ciudad => usuario.ciudad;

  @override
  List<Object?> get props => [id, ci, edad, telefono, fechaNacimiento, usuario];
}
