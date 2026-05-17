import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cambiar_estado_cita.dart';
import '../../domain/usecases/listar_citas.dart';
import '../../domain/usecases/listar_servicios_cita.dart';
import '../../domain/usecases/modificar_cita.dart';
import '../../domain/usecases/obtener_horas_disponibles.dart';
import '../../domain/usecases/reservar_cita.dart';
import 'cita_event.dart';
import 'cita_state.dart';

class CitaBloc extends Bloc<CitaEvent, CitaState> {
  final ListarCitasUseCase listarCitasUseCase;
  final ReservarCitaUseCase reservarCitaUseCase;
  final ModificarCitaUseCase modificarCitaUseCase;
  final CambiarEstadoCitaUseCase cambiarEstadoCitaUseCase;
  final ListarServiciosCitaUseCase listarServiciosCitaUseCase;
  final ObtenerHorasDisponiblesUseCase obtenerHorasDisponiblesUseCase;

  CitaBloc({
    required this.listarCitasUseCase,
    required this.reservarCitaUseCase,
    required this.modificarCitaUseCase,
    required this.cambiarEstadoCitaUseCase,
    required this.listarServiciosCitaUseCase,
    required this.obtenerHorasDisponiblesUseCase,
  }) : super(CitaInitial()) {
    on<ListarCitasEvent>(_onListar);
    on<ReservarCitaEvent>(_onReservar);
    on<ModificarCitaEvent>(_onModificar);
    on<CambiarEstadoCitaEvent>(_onCambiarEstado);
    on<CargarServiciosEvent>(_onCargarServicios);
    on<CargarDisponibilidadEvent>(_onCargarDisponibilidad);
  }

  Future<void> _onListar(
    ListarCitasEvent event,
    Emitter<CitaState> emit,
  ) async {
    emit(CitaLoading());
    try {
      final citas = await listarCitasUseCase.execute();
      emit(CitasListadas(citas));
    } catch (e) {
      emit(CitaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onReservar(
    ReservarCitaEvent event,
    Emitter<CitaState> emit,
  ) async {
    emit(CitaLoading());
    try {
      await reservarCitaUseCase.execute(
        fecha: event.fecha,
        hora: event.hora,
        servicioId: event.servicioId,
        pacienteId: event.pacienteId,
        ciudadId: event.ciudadId,
        agendaId: event.agendaId,
        notas: event.notas,
      );
      emit(CitaReservada());
    } catch (e) {
      emit(CitaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onModificar(
    ModificarCitaEvent event,
    Emitter<CitaState> emit,
  ) async {
    emit(CitaLoading());
    try {
      await modificarCitaUseCase.execute(
        id: event.id,
        fecha: event.fecha,
        hora: event.hora,
        servicioId: event.servicioId,
        notas: event.notas,
      );
      emit(CitaModificada());
    } catch (e) {
      emit(CitaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCambiarEstado(
    CambiarEstadoCitaEvent event,
    Emitter<CitaState> emit,
  ) async {
    emit(CitaLoading());
    try {
      await cambiarEstadoCitaUseCase.execute(
        event.id,
        event.estado,
        notas: event.notas,
      );
      emit(EstadoCitaCambiado());
    } catch (e) {
      emit(CitaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarServicios(
    CargarServiciosEvent event,
    Emitter<CitaState> emit,
  ) async {
    emit(CitaLoading());
    try {
      final servicios = await listarServiciosCitaUseCase.execute();
      emit(ServiciosCargados(servicios));
    } catch (e) {
      emit(CitaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarDisponibilidad(
    CargarDisponibilidadEvent event,
    Emitter<CitaState> emit,
  ) async {
    emit(CitaLoading());
    try {
      final horas = await obtenerHorasDisponiblesUseCase.execute(
        ciudadId: event.ciudadId,
        fecha: event.fecha,
      );
      emit(DisponibilidadCargada(horasDisponibles: horas, fecha: event.fecha));
    } catch (e) {
      emit(CitaError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
