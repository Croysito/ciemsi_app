import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

class Agenda extends Equatable {
  final int id;
  final DateTime? fecha;
  final List<String>? diasSemana;
  final String horaInicio;
  final String horaFin;
  final int intervalo;
  final Ciudad ciudad;
  final bool estado;
  final String? rolCreador;
  final List<Servicio>? servicios;

  const Agenda({
    required this.id,
    this.fecha,
    this.diasSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.intervalo,
    required this.ciudad,
    required this.estado,
    this.rolCreador,
    this.servicios,
  });

  @override
  List<Object?> get props => [
    id,
    fecha,
    diasSemana,
    horaInicio,
    horaFin,
    intervalo,
    ciudad,
    estado,
    rolCreador,
    servicios,
  ];
}
