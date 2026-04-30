import 'package:equatable/equatable.dart';

abstract class TratamientoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListarTratamientosEvent extends TratamientoEvent {}

class CrearTratamientoEvent extends TratamientoEvent {
  final String nombreTratamiento;
  final String? detalle;
  final double? precioBase;

  CrearTratamientoEvent({
    required this.nombreTratamiento,
    this.detalle,
    this.precioBase,
  });

  @override
  List<Object?> get props => [nombreTratamiento];
}

class AsignarTratamientoEvent extends TratamientoEvent {
  final int tratamientoId;
  final int citaId;
  final double? precio;
  final List<Map<String, dynamic>>? medicamentos;

  AsignarTratamientoEvent({
    required this.tratamientoId,
    required this.citaId,
    this.precio,
    this.medicamentos,
  });

  @override
  List<Object?> get props => [tratamientoId, citaId];
}

class ListarAsignadosEvent extends TratamientoEvent {}

class ListarAsignadosByCitaEvent extends TratamientoEvent {
  final int citaId;
  ListarAsignadosByCitaEvent(this.citaId);
  @override
  List<Object?> get props => [citaId];
}

class AgregarSuministroEvent extends TratamientoEvent {
  final int tratamientoAsignadoId;
  final int suministroId;
  final int cantidad;

  AgregarSuministroEvent({
    required this.tratamientoAsignadoId,
    required this.suministroId,
    required this.cantidad,
  });

  @override
  List<Object?> get props => [tratamientoAsignadoId, suministroId, cantidad];
}

class CompletarTratamientoEvent extends TratamientoEvent {
  final int id;
  CompletarTratamientoEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class GenerarRecetaEvent extends TratamientoEvent {
  final int citaId;
  final String detalle;

  GenerarRecetaEvent({required this.citaId, required this.detalle});

  @override
  List<Object?> get props => [citaId, detalle];
}
