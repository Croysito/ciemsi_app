import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/agenda/data/models/agenda_model.dart';
import 'package:ciemsi_app/features/agenda/domain/usecases/cambiar_estado_agenda.dart';
import 'package:ciemsi_app/features/agenda/domain/usecases/crear_agenda_usecase.dart';
import 'package:ciemsi_app/features/agenda/domain/usecases/eliminar_agenda.dart';
import 'package:ciemsi_app/features/agenda/domain/usecases/listar_agendas.dart';
import 'package:ciemsi_app/features/agenda/domain/usecases/listar_ciudades_agenda.dart';
import 'agenda_event.dart';
import 'agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  final ListarAgendasUseCase listarAgendasUseCase;
  final CrearAgendaUseCase crearAgendaUseCase;
  final CambiarEstadoAgendaUseCase cambiarEstadoAgendaUseCase;
  final EliminarAgendaUseCase eliminarAgendaUseCase;
  final ListarCiudadesAgendaUseCase listarCiudadesAgendaUseCase;

  AgendaBloc({
    required this.listarAgendasUseCase,
    required this.crearAgendaUseCase,
    required this.cambiarEstadoAgendaUseCase,
    required this.eliminarAgendaUseCase,
    required this.listarCiudadesAgendaUseCase,
  }) : super(AgendaInitial()) {
    on<CargarAgendasEvent>(_onCargarAgendas);
    on<CambiarEstadoAgendaEvent>(_onCambiarEstado);
    on<EliminarAgendaEvent>(_onEliminar);
    on<CargarCiudadesAgendaEvent>(_onCargarCiudades);
    on<CrearAgendaEvent>(_onCrear);
  }

  Future<void> _onCargarAgendas(
    CargarAgendasEvent event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      final agendas = await listarAgendasUseCase.execute(
        ciudadId: event.ciudadId,
      );
      emit(AgendasCargadas(agendas.cast<AgendaModel>()));
    } catch (e) {
      emit(AgendaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCambiarEstado(
    CambiarEstadoAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      await cambiarEstadoAgendaUseCase.execute(event.id, event.estado);
      emit(AgendaOperacionExitosa());
    } catch (e) {
      emit(AgendaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onEliminar(
    EliminarAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      await eliminarAgendaUseCase.execute(event.id);
      emit(AgendaOperacionExitosa());
    } catch (e) {
      emit(AgendaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarCiudades(
    CargarCiudadesAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      final ciudades = await listarCiudadesAgendaUseCase.execute();
      emit(CiudadesAgendaCargadas(ciudades));
    } catch (e) {
      emit(AgendaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCrear(
    CrearAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      await crearAgendaUseCase.execute(event.datos);
      emit(AgendaOperacionExitosa());
    } catch (e) {
      emit(AgendaError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
