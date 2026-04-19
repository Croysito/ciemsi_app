import 'package:equatable/equatable.dart';

abstract class HistorialEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ObtenerHistorialEvent extends HistorialEvent {
  final int pacienteId;
  ObtenerHistorialEvent(this.pacienteId);

  @override
  List<Object?> get props => [pacienteId];
}

class AgregarNotaEvent extends HistorialEvent {
  final int pacienteId;
  final String detalle;
  AgregarNotaEvent({required this.pacienteId, required this.detalle});

  @override
  List<Object?> get props => [pacienteId, detalle];
}

class AgregarLinkEvent extends HistorialEvent {
  final int notaId;
  final String nombre;
  final String link;
  final String tipo;

  AgregarLinkEvent({
    required this.notaId,
    required this.nombre,
    required this.link,
    required this.tipo,
  });

  @override
  List<Object?> get props => [notaId, nombre, link, tipo];
}

class SubirArchivoDriveEvent extends HistorialEvent {
  final int notaId;
  final String tipo;
  final String tokens;
  final List<int> bytes;
  final String nombre;
  final String mimeType;

  SubirArchivoDriveEvent({
    required this.notaId,
    required this.tipo,
    required this.tokens,
    required this.bytes,
    required this.nombre,
    required this.mimeType,
  });

  @override
  List<Object?> get props => [notaId, tipo, nombre];
}
