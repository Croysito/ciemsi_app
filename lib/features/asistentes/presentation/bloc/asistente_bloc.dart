import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/asistentes/data/datasources/asistente_remote_datasource.dart';
import 'asistente_event.dart';
import 'asistente_state.dart';

class AsistenteBloc extends Bloc<AsistenteEvent, AsistenteState> {
  final AsistenteRemoteDatasource datasource;

  AsistenteBloc()
    : datasource = AsistenteRemoteDatasource(ApiClientProvider.instance),
      super(AsistenteInitial()) {
    on<ListarAsistentesEvent>(_onListar);
    on<CrearAsistenteEvent>(_onCrear);
    on<ModificarAsistenteEvent>(_onModificar);
    on<CambiarEstadoAsistenteEvent>(_onCambiarEstado);
    on<CambiarPasswordEvent>(_onCambiarPassword);
  }

  Future<void> _onListar(
    ListarAsistentesEvent event,
    Emitter<AsistenteState> emit,
  ) async {
    emit(AsistenteLoading());
    try {
      final asistentes = await datasource.listarAsistentes();
      emit(AsistentesListados(asistentes));
    } catch (e) {
      emit(AsistenteError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCrear(
    CrearAsistenteEvent event,
    Emitter<AsistenteState> emit,
  ) async {
    emit(AsistenteLoading());
    try {
      final resultado = await datasource.crearAsistente(
        nombre: event.nombre,
        apellido: event.apellido,
        email: event.email,
        ci: event.ci,
        ciudadId: event.ciudadId,
      );
      emit(
        AsistenteCreado(
          email: resultado['credenciales']['email'],
          password: resultado['credenciales']['password'],
        ),
      );
    } catch (e) {
      emit(AsistenteError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onModificar(
    ModificarAsistenteEvent event,
    Emitter<AsistenteState> emit,
  ) async {
    emit(AsistenteLoading());
    try {
      await datasource.modificarAsistente(
        id: event.id,
        nombre: event.nombre,
        apellido: event.apellido,
        email: event.email,
        ciudadId: event.ciudadId,
      );
      emit(AsistenteModificado());
    } catch (e) {
      emit(AsistenteError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCambiarEstado(
    CambiarEstadoAsistenteEvent event,
    Emitter<AsistenteState> emit,
  ) async {
    emit(AsistenteLoading());
    try {
      await datasource.cambiarEstado(event.id, event.estado);
      emit(EstadoCambiado());
    } catch (e) {
      emit(AsistenteError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCambiarPassword(
    CambiarPasswordEvent event,
    Emitter<AsistenteState> emit,
  ) async {
    emit(AsistenteLoading());
    try {
      await datasource.cambiarPassword(
        passwordActual: event.passwordActual,
        passwordNuevo: event.passwordNuevo,
      );
      emit(PasswordCambiado());
    } catch (e) {
      emit(AsistenteError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
