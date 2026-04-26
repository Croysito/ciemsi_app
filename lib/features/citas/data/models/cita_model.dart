import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/pacientes/data/models/paciente_model.dart';
import 'package:ciemsi_app/features/pacientes/data/models/ciudad_model.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

class CitaModel extends CitaMedica {
  const CitaModel({
    required super.id,
    required super.fecha,
    required super.hora,
    required super.paciente,
    required super.servicio,
    required super.ciudad,
    required super.estado,
    super.notas,
    required super.creadoPor,
    required super.createdAt,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    EstadoCita estado = EstadoCita.values.firstWhere(
      (e) => e.name == json['estado'],
      orElse: () => EstadoCita.PENDIENTE,
    );

    return CitaModel(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      hora: json['hora'],
      paciente: PacienteModel.fromJson(json['paciente']),
      servicio: Servicio(
        id: json['servicio']['id'],
        nombreServicio: json['servicio']['nombreServicio'],
        tiempoMin: json['servicio']['tiempoMin'],
        estado: true,
      ),
      ciudad: CiudadModel.fromJson(json['ciudad']),
      estado: estado,
      notas: json['notas'],
      creadoPor: json['creadoPor'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
