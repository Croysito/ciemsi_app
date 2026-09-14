import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/paciente.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

enum EstadoCita { PENDIENTE, PENDIENTE_PAGO, MODIFICADA, CONFIRMADA, CANCELADA, COMPLETADA }

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
  final double? adelantoMonto;
  final String? adelantoMetodo;
  final String? comprobantePath;

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
    this.adelantoMonto,
    this.adelantoMetodo,
    this.comprobantePath,
  });

  bool get tieneComprobante => comprobantePath != null && comprobantePath!.isNotEmpty;

  CitaMedica copyWith({
    EstadoCita? estado,
    String? notas,
    double? adelantoMonto,
    String? adelantoMetodo,
    String? comprobantePath,
  }) {
    return CitaMedica(
      id: id,
      fecha: fecha,
      hora: hora,
      paciente: paciente,
      servicio: servicio,
      ciudad: ciudad,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      creadoPor: creadoPor,
      createdAt: createdAt,
      adelantoMonto: adelantoMonto ?? this.adelantoMonto,
      adelantoMetodo: adelantoMetodo ?? this.adelantoMetodo,
      comprobantePath: comprobantePath ?? this.comprobantePath,
    );
  }

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
