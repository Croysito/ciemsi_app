import 'package:equatable/equatable.dart';

abstract class CitaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListarCitasEvent extends CitaEvent {}

class ReservarCitaEvent extends CitaEvent {
  final String fecha;
  final String hora;
  final int servicioId;
  final int? pacienteId;
  final int? ciudadId;
  final int? agendaId;
  final String? notas;
  final bool esPaciente;
  final double? adelantoMonto;
  final String? adelantoMetodo;

  ReservarCitaEvent({
    required this.fecha,
    required this.hora,
    required this.servicioId,
    this.pacienteId,
    this.ciudadId,
    this.agendaId,
    this.notas,
    this.esPaciente = false,
    this.adelantoMonto,
    this.adelantoMetodo,
  });

  @override
  List<Object?> get props => [fecha, hora, servicioId, pacienteId, ciudadId, agendaId];
}

class ModificarCitaEvent extends CitaEvent {
  final int id;
  final String fecha;
  final String hora;
  final int servicioId;
  final String? notas;

  ModificarCitaEvent({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.servicioId,
    this.notas,
  });

  @override
  List<Object?> get props => [id, fecha, hora, servicioId];
}

class CambiarEstadoCitaEvent extends CitaEvent {
  final int id;
  final String estado;
  final String? notas;

  CambiarEstadoCitaEvent({required this.id, required this.estado, this.notas});

  @override
  List<Object?> get props => [id, estado];
}

class CargarServiciosEvent extends CitaEvent {}

class CargarDisponibilidadEvent extends CitaEvent {
  final int ciudadId;
  final String fecha;

  CargarDisponibilidadEvent({required this.ciudadId, required this.fecha});

  @override
  List<Object?> get props => [ciudadId, fecha];
}

class ObtenerQrPagoEvent extends CitaEvent {}

class ActualizarQrPagoEvent extends CitaEvent {
  final String qrLink;
  ActualizarQrPagoEvent(this.qrLink);
  @override
  List<Object?> get props => [qrLink];
}

class SubirComprobanteEvent extends CitaEvent {
  final int citaId;
  final List<int> bytes;
  final String fileName;
  final String mimeType;
  SubirComprobanteEvent({
    required this.citaId,
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });
  @override
  List<Object?> get props => [citaId, fileName];
}

class ConfirmarPagoEvent extends CitaEvent {
  final int citaId;
  ConfirmarPagoEvent(this.citaId);
  @override
  List<Object?> get props => [citaId];
}
