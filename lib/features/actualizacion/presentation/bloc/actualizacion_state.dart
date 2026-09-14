import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/actualizacion/domain/entities/version_disponible.dart';

abstract class ActualizacionState extends Equatable {
  const ActualizacionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial, o sin novedad (ya está en la última versión, o no se
/// pudo consultar) — en ambos casos no se muestra nada al usuario.
class ActualizacionInicial extends ActualizacionState {
  const ActualizacionInicial();
}

class ActualizacionDisponible extends ActualizacionState {
  final VersionDisponible version;

  const ActualizacionDisponible(this.version);

  @override
  List<Object?> get props => [version];
}

class ActualizacionDescargando extends ActualizacionState {
  final VersionDisponible version;
  final double progreso; // 0.0 a 1.0

  const ActualizacionDescargando(this.version, this.progreso);

  @override
  List<Object?> get props => [version, progreso];
}

class ActualizacionListaParaInstalar extends ActualizacionState {
  final VersionDisponible version;
  final String rutaArchivo;

  const ActualizacionListaParaInstalar(this.version, this.rutaArchivo);

  @override
  List<Object?> get props => [version, rutaArchivo];
}

class ActualizacionError extends ActualizacionState {
  final VersionDisponible version;
  final String mensaje;

  const ActualizacionError(this.version, this.mensaje);

  @override
  List<Object?> get props => [version, mensaje];
}
