import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/citas/domain/entities/disponibilidad_dia.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

abstract class CitaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CitaInitial extends CitaState {}

class CitaLoading extends CitaState {}

class CitasListadas extends CitaState {
  final List<CitaMedica> citas;
  CitasListadas(this.citas);

  @override
  List<Object?> get props => [citas];
}

/// Una sola cita actualizada (respuesta de [ObtenerCitaEvent]).
class CitaObtenida extends CitaState {
  final CitaMedica cita;
  CitaObtenida(this.cita);
  @override
  List<Object?> get props => [cita];
}

class DisponibilidadMesCargada extends CitaState {
  final List<DisponibilidadDia> dias;
  final int anio;
  final int mes;
  DisponibilidadMesCargada({required this.dias, required this.anio, required this.mes});
  @override
  List<Object?> get props => [dias, anio, mes];
}

class CitaReservada extends CitaState {}

class CitaModificada extends CitaState {}

class EstadoCitaCambiado extends CitaState {}

class ServiciosCargados extends CitaState {
  final List<Servicio> servicios;
  ServiciosCargados(this.servicios);

  @override
  List<Object?> get props => [servicios];
}

class DisponibilidadCargada extends CitaState {
  final List<String> horasDisponibles;
  final String fecha;
  DisponibilidadCargada({required this.horasDisponibles, required this.fecha});

  @override
  List<Object?> get props => [horasDisponibles, fecha];
}

class QrPagoCargado extends CitaState {
  final String? qrLink;
  final double adelantoMonto;
  QrPagoCargado({required this.qrLink, required this.adelantoMonto});
  @override
  List<Object?> get props => [qrLink, adelantoMonto];
}

class QrPagoActualizado extends CitaState {}

class ComprobanteSubido extends CitaState {
  final int citaId;
  ComprobanteSubido(this.citaId);
  @override
  List<Object?> get props => [citaId];
}

class PagoConfirmado extends CitaState {}

// CitaReservada ahora incluye el citaId para redirigir al pago
class CitaReservadaConPago extends CitaState {
  final int citaId;
  CitaReservadaConPago(this.citaId);
  @override
  List<Object?> get props => [citaId];
}

class CitaError extends CitaState {
  final String mensaje;
  CitaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
