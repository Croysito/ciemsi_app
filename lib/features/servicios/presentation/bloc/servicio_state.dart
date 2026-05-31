import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

abstract class ServicioState {}

class ServicioInitial extends ServicioState {}

class ServicioLoading extends ServicioState {}

class ServiciosCargados extends ServicioState {
  final List<Servicio> servicios;
  ServiciosCargados(this.servicios);
}

class ServicioOperacionExitosa extends ServicioState {}

class ServicioError extends ServicioState {
  final String mensaje;
  ServicioError(this.mensaje);
}
