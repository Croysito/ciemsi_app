import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/paciente.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

enum EstadoCita { PENDIENTE, MODIFICADA, CONFIRMADA, CANCELADA, COMPLETADA }

class CitaMedica extends Equatable {
  final int id;
  final DateTime fecha;
  final String hora;
  final Paciente paciente;
  final Servicio servicio;
  final Ciudad ciudad;
  final EstadoCita estado;
  final String? notas;
  final Map<String, dynamic> creadoPor;
  final DateTime createdAt;

  const CitaMedica({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.paciente,
    required this.servicio,
    required this.ciudad,
    required this.estado,
    this.notas,
    required this.creadoPor,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    fecha,
    hora,
    paciente,
    servicio,
    ciudad,
    estado,
  ];
}
