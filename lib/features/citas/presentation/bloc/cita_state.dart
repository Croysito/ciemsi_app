import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
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

class CitaError extends CitaState {
  final String mensaje;
  CitaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
