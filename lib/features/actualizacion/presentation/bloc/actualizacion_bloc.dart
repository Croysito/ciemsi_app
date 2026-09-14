import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/actualizacion/domain/usecases/descargar_actualizacion.dart';
import 'package:ciemsi_app/features/actualizacion/domain/usecases/instalar_actualizacion.dart';
import 'package:ciemsi_app/features/actualizacion/domain/usecases/verificar_actualizacion.dart';
import 'package:ciemsi_app/features/actualizacion/presentation/bloc/actualizacion_event.dart';
import 'package:ciemsi_app/features/actualizacion/presentation/bloc/actualizacion_state.dart';

class ActualizacionBloc extends Bloc<ActualizacionEvent, ActualizacionState> {
  final VerificarActualizacionUseCase verificarActualizacionUseCase;
  final DescargarActualizacionUseCase descargarActualizacionUseCase;
  final InstalarActualizacionUseCase instalarActualizacionUseCase;

  ActualizacionBloc({
    required this.verificarActualizacionUseCase,
    required this.descargarActualizacionUseCase,
    required this.instalarActualizacionUseCase,
  }) : super(const ActualizacionInicial()) {
    on<VerificarActualizacionEvent>(_onVerificar);
    on<DescargarActualizacionEvent>(_onDescargar);
    on<InstalarActualizacionEvent>(_onInstalar);
    on<DescartarActualizacionEvent>(_onDescartar);
  }

  Future<void> _onVerificar(
    VerificarActualizacionEvent event,
    Emitter<ActualizacionState> emit,
  ) async {
    final version = await verificarActualizacionUseCase();
    if (version != null) {
      emit(ActualizacionDisponible(version));
    }
  }

  Future<void> _onDescargar(
    DescargarActualizacionEvent event,
    Emitter<ActualizacionState> emit,
  ) async {
    emit(ActualizacionDescargando(event.version, 0));
    try {
      final ruta = await descargarActualizacionUseCase(
        event.version.urlDescarga,
        onProgreso: (progreso) {
          // emit fuera del ciclo síncrono del handler: usamos el emitter
          // solo si el bloc sigue activo para evitar el error de "emit
          // after handler completed".
          if (!isClosed) {
            emit(ActualizacionDescargando(event.version, progreso));
          }
        },
      );
      if (isClosed) return;

      final permisoOk = await instalarActualizacionUseCase.solicitarPermiso();
      if (!permisoOk) {
        emit(
          ActualizacionError(
            event.version,
            'Para instalar la actualización, autorizá a CIEMSI a instalar '
            'aplicaciones desconocidas desde Ajustes.',
          ),
        );
        return;
      }

      emit(ActualizacionListaParaInstalar(event.version, ruta));
      await instalarActualizacionUseCase(ruta);
    } catch (e) {
      if (!isClosed) {
        emit(ActualizacionError(event.version, e.toString()));
      }
    }
  }

  Future<void> _onInstalar(
    InstalarActualizacionEvent event,
    Emitter<ActualizacionState> emit,
  ) async {
    final estado = state;
    if (estado is! ActualizacionListaParaInstalar) return;
    try {
      await instalarActualizacionUseCase(estado.rutaArchivo);
    } catch (e) {
      emit(ActualizacionError(estado.version, e.toString()));
    }
  }

  void _onDescartar(
    DescartarActualizacionEvent event,
    Emitter<ActualizacionState> emit,
  ) {
    emit(const ActualizacionInicial());
  }
}
