import 'package:ciemsi_app/features/agenda/domain/entities/agenda.dart';
import 'package:ciemsi_app/features/pacientes/data/models/ciudad_model.dart';
import 'package:ciemsi_app/features/servicios/data/models/servicio_model.dart';

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
    super.rolCreador,
    super.servicios,
  });

  static List<ServicioModel>? _parseServicios(dynamic raw) {
    if (raw == null) return null;
    try {
      final lista = raw as List;
      if (lista.isEmpty) return [];
      return lista.map((s) {
        final map = s as Map<String, dynamic>;
        if (map['servicio'] is Map<String, dynamic>) {
          return ServicioModel.fromJson(map['servicio'] as Map<String, dynamic>);
        }
        return ServicioModel.fromJson(map);
      }).toList();
    } catch (_) {
      return null;
    }
  }

  static List<String>? _parseDiasSemana(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) return List<String>.from(raw);
    if (raw is String) {
      // PostgreSQL devuelve arrays como "{LUNES,MIERCOLES}"
      final cleaned = raw.replaceAll('{', '').replaceAll('}', '').trim();
      if (cleaned.isEmpty) return null;
      return cleaned.split(',').map((s) => s.trim()).toList();
    }
    return null;
  }

  static String? _parseRolCreador(dynamic raw) {
    final rol = raw?.toString().toUpperCase();
    if (rol == null || rol.isEmpty) return null;
    if (rol == 'MEDICO' || rol == 'DOCTOR' || rol == 'DOCTORA') {
      return 'Doctora';
    }
    if (rol == 'ASISTENTE') return 'Asistente';
    return raw.toString();
  }

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    final ciudadRaw = json['ciudad'];
    final CiudadModel ciudad;
    if (ciudadRaw is Map<String, dynamic>) {
      ciudad = CiudadModel.fromJson(ciudadRaw);
    } else {
      ciudad = CiudadModel(
        id: json['ciudadId'] ?? 0,
        nombreCiudad: '',
      );
    }

    return AgendaModel(
      id: json['id'],
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString())
          : null,
      diasSemana: _parseDiasSemana(json['diasSemana']),
      horaInicio: json['horaInicio'] ?? '',
      horaFin: json['horaFin'] ?? '',
      intervalo: json['intervalo'] ?? 30,
      ciudad: ciudad,
      estado: json['estado'] ?? true,
      rolCreador: _parseRolCreador(
        json['rolCreador'] ?? json['usuario']?['rol'],
      ),
      servicios: _parseServicios(json['servicios']),
    );
  }
}
