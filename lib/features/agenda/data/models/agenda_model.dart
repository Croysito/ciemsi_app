import 'package:ciemsi_app/features/agenda/domain/entities/agenda.dart';
import 'package:ciemsi_app/features/pacientes/data/models/ciudad_model.dart';

class AgendaModel extends Agenda {
  const AgendaModel({
    required super.id,
    super.fecha,
    super.diasSemana,
    required super.horaInicio,
    required super.horaFin,
    required super.intervalo,
    required super.ciudad,
    required super.estado,
  });

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      id: json['id'],
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : null,
      diasSemana: json['diasSemana'] != null
          ? List<String>.from(json['diasSemana'])
          : null,
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
      intervalo: json['intervalo'] ?? 30,
      ciudad: CiudadModel.fromJson(json['ciudad']),
      estado: json['estado'] ?? true,
    );
  }
}
