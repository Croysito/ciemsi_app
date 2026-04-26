import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/citas/data/datasources/cita_remote_datasource.dart';
import 'cita_event.dart';
import 'cita_state.dart';

class CitaBloc extends Bloc<CitaEvent, CitaState> {
  final CitaRemoteDatasource datasource;

  CitaBloc()
    : datasource = CitaRemoteDatasource(ApiClientProvider.instance),
      super(CitaInitial()) {
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
      final citas = await datasource.listarCitas();
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
      await datasource.reservarCita(
        fecha: event.fecha,
        hora: event.hora,
        servicioId: event.servicioId,
        pacienteId: event.pacienteId,
        ciudadId: event.ciudadId,
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
      await datasource.modificarCita(
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
      await datasource.cambiarEstado(
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
      final servicios = await datasource.listarServicios();
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
      final resultado = await datasource.obtenerDisponibilidad(
        ciudadId: event.ciudadId,
        fecha: event.fecha,
      );
      final horas = List<String>.from(resultado['horasDisponibles'] ?? []);
      emit(DisponibilidadCargada(horasDisponibles: horas, fecha: event.fecha));
    } catch (e) {
      emit(CitaError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
