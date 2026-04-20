import 'package:equatable/equatable.dart';
import 'ciudad.dart';
import '../../../auth/domain/entities/usuario.dart';

class Paciente extends Equatable {
  final int id;
  final String ci;
  final int? edad;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final Ciudad ciudad;
  final Usuario usuario;

  const Paciente({
    required this.id,
    required this.ci,
    this.edad,
    this.telefono,
    this.fechaNacimiento,
    required this.ciudad,
    required this.usuario,
  });

  String get nombreCompleto => '${usuario.nombre} ${usuario.apellido}';

  @override
  List<Object?> get props => [
    id,
    ci,
    edad,
    telefono,
    fechaNacimiento,
    ciudad,
    usuario,
  ];
}
