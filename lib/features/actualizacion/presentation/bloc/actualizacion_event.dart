import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/actualizacion/domain/entities/version_disponible.dart';

abstract class ActualizacionEvent extends Equatable {
  const ActualizacionEvent();

  @override
  List<Object?> get props => [];
}

/// Se dispara al arrancar la app para ver si hay una versión más nueva.
class VerificarActualizacionEvent extends ActualizacionEvent {
  const VerificarActualizacionEvent();
}

/// El usuario tocó "Actualizar ahora" en el diálogo.
class DescargarActualizacionEvent extends ActualizacionEvent {
  final VersionDisponible version;

  const DescargarActualizacionEvent(this.version);

  @override
  List<Object?> get props => [version];
}

/// El usuario tocó "Instalar" luego de que terminó la descarga.
class InstalarActualizacionEvent extends ActualizacionEvent {
  const InstalarActualizacionEvent();
}

/// El usuario descartó el aviso ("Ahora no").
class DescartarActualizacionEvent extends ActualizacionEvent {
  const DescartarActualizacionEvent();
}
