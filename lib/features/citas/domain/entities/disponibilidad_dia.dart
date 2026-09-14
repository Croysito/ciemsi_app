import 'package:equatable/equatable.dart';

/// Resumen de disponibilidad de un día, tal como lo devuelve
/// `GET /agenda/disponibilidad-mes` (una llamada por mes, en vez de una
/// llamada por día).
class DisponibilidadDia extends Equatable {
  final DateTime fecha;
  final bool tieneHorario;
  final int cuposLibres;

  const DisponibilidadDia({
    required this.fecha,
    required this.tieneHorario,
    required this.cuposLibres,
  });

  factory DisponibilidadDia.fromJson(Map<String, dynamic> json) {
    return DisponibilidadDia(
      fecha: DateTime.parse(json['fecha'] as String),
      tieneHorario: json['tieneHorario'] as bool? ?? false,
      cuposLibres: (json['cuposLibres'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [fecha, tieneHorario, cuposLibres];
}
