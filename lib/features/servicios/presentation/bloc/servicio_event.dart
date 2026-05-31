import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

abstract class ServicioEvent {}

class CargarServiciosEvent extends ServicioEvent {}

class CrearServicioEvent extends ServicioEvent {
  final Map<String, dynamic> datos;
  CrearServicioEvent(this.datos);
}

class ModificarServicioEvent extends ServicioEvent {
  final Servicio servicio;
  final Map<String, dynamic> datos;
  ModificarServicioEvent(this.servicio, this.datos);
}
