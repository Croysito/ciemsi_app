import 'package:equatable/equatable.dart';

abstract class SuministroEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListarSuministrosEvent extends SuministroEvent {
  final String? tipo;
  ListarSuministrosEvent({this.tipo});
  @override
  List<Object?> get props => [tipo];
}

class CrearSuministroEvent extends SuministroEvent {
  final String nombreSuministro;
  final String unidadMedida;
  final String? marca;
  final String tipo;
  final int umbral;

  CrearSuministroEvent({
    required this.nombreSuministro,
    required this.unidadMedida,
    this.marca,
    required this.tipo,
    required this.umbral,
  });

  @override
  List<Object?> get props => [nombreSuministro, tipo];
}

class ObtenerInventarioEvent extends SuministroEvent {
  final int ciudadId;
  ObtenerInventarioEvent(this.ciudadId);
  @override
  List<Object?> get props => [ciudadId];
}

class ObtenerAlertasEvent extends SuministroEvent {
  final int ciudadId;
  ObtenerAlertasEvent(this.ciudadId);
  @override
  List<Object?> get props => [ciudadId];
}

class RegistrarCompraEvent extends SuministroEvent {
  final int ciudadId;
  final List<Map<String, dynamic>> items;
  final String? fecha;

  RegistrarCompraEvent({
    required this.ciudadId,
    required this.items,
    this.fecha,
  });

  @override
  List<Object?> get props => [ciudadId, items];
}

class CargarSuministrosCatalogoEvent extends SuministroEvent {}
