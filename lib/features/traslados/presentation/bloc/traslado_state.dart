import 'package:equatable/equatable.dart';
import '../../domain/entities/traslado.dart';
import '../../domain/entities/traslado_datos_creacion.dart';

abstract class TrasladoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TrasladoInitial extends TrasladoState {}

class TrasladoLoading extends TrasladoState {}

class TrasladoDatosCreacionLoading extends TrasladoState {}

class TrasladoDatosCreacionCargados extends TrasladoState {
  final TrasladoDatosCreacion datos;

  TrasladoDatosCreacionCargados(this.datos);

  @override
  List<Object?> get props => [datos];
}

class TrasladoStockLoading extends TrasladoState {}

class TrasladoStockCargado extends TrasladoState {
  final double disponible;

  TrasladoStockCargado(this.disponible);

  @override
  List<Object?> get props => [disponible];
}

class TrasladosListados extends TrasladoState {
  final List<Traslado> traslados;
  TrasladosListados(this.traslados);
  @override
  List<Object?> get props => [traslados];
}

class TrasladoOperacionExitosa extends TrasladoState {
  final int ciudadId;
  TrasladoOperacionExitosa(this.ciudadId);
  @override
  List<Object?> get props => [ciudadId];
}

class TrasladoError extends TrasladoState {
  final String mensaje;
  TrasladoError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
