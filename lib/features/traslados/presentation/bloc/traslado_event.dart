import 'package:equatable/equatable.dart';

abstract class TrasladoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListarTrasladosEvent extends TrasladoEvent {
  final int ciudadId;
  ListarTrasladosEvent(this.ciudadId);
  @override
  List<Object?> get props => [ciudadId];
}

class CargarDatosCreacionTrasladoEvent extends TrasladoEvent {
  final int ciudadOrigenId;

  CargarDatosCreacionTrasladoEvent(this.ciudadOrigenId);

  @override
  List<Object?> get props => [ciudadOrigenId];
}

class ConsultarStockTrasladoEvent extends TrasladoEvent {
  final String tipo;
  final int itemId;
  final int ciudadOrigenId;

  ConsultarStockTrasladoEvent({
    required this.tipo,
    required this.itemId,
    required this.ciudadOrigenId,
  });

  @override
  List<Object?> get props => [tipo, itemId, ciudadOrigenId];
}

class CrearTrasladoEvent extends TrasladoEvent {
  final String tipo;
  final int? suministroId;
  final int? productoId;
  final int ciudadOrigenId;
  final int ciudadDestinoId;
  final double cantidad;

  CrearTrasladoEvent({
    required this.tipo,
    this.suministroId,
    this.productoId,
    required this.ciudadOrigenId,
    required this.ciudadDestinoId,
    required this.cantidad,
  });

  @override
  List<Object?> get props => [
    tipo,
    suministroId,
    productoId,
    ciudadOrigenId,
    ciudadDestinoId,
    cantidad,
  ];
}

class ConfirmarTrasladoEvent extends TrasladoEvent {
  final int id;
  final int ciudadId;
  ConfirmarTrasladoEvent(this.id, this.ciudadId);
  @override
  List<Object?> get props => [id, ciudadId];
}

class DevolverTrasladoEvent extends TrasladoEvent {
  final int id;
  final int ciudadId;
  DevolverTrasladoEvent(this.id, this.ciudadId);
  @override
  List<Object?> get props => [id, ciudadId];
}
