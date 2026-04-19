import 'package:equatable/equatable.dart';
import '../../domain/entities/historial_clinico.dart';
import '../../domain/entities/nota_evolucion.dart';
import '../../domain/entities/link_archivo.dart';

abstract class HistorialState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HistorialInitial extends HistorialState {}

class HistorialLoading extends HistorialState {}

class HistorialObtenido extends HistorialState {
  final HistorialClinico historial;
  HistorialObtenido(this.historial);

  @override
  List<Object?> get props => [historial];
}

class NotaAgregada extends HistorialState {
  final NotaEvolucion nota;
  NotaAgregada(this.nota);

  @override
  List<Object?> get props => [nota];
}

class LinkAgregado extends HistorialState {
  final LinkArchivo link;
  LinkAgregado(this.link);

  @override
  List<Object?> get props => [link];
}

class ArchivoSubido extends HistorialState {
  final LinkArchivo link;
  ArchivoSubido(this.link);

  @override
  List<Object?> get props => [link];
}

class HistorialError extends HistorialState {
  final String mensaje;
  HistorialError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
