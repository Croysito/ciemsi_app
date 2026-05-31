import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';

class Paciente extends Equatable {
  final int id;
  final String ci;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final String? genero;
  final Usuario usuario;

  const Paciente({
    required this.id,
    required this.ci,
    this.telefono,
    this.fechaNacimiento,
    this.genero,
    required this.usuario,
  });

  String get nombreCompleto => usuario.nombreCompleto;
  Ciudad? get ciudad => usuario.ciudad;

  int? get edad {
    if (fechaNacimiento == null) return null;
    final hoy = DateTime.now();
    int anios = hoy.year - fechaNacimiento!.year;
    if (hoy.month < fechaNacimiento!.month ||
        (hoy.month == fechaNacimiento!.month &&
            hoy.day < fechaNacimiento!.day)) {
      anios--;
    }
    return anios;
  }

  @override
  List<Object?> get props => [id, ci, telefono, fechaNacimiento, genero, usuario];
}
