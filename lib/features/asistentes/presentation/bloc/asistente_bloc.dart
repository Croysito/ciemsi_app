import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cambiar_estado_asistente.dart';
import '../../domain/usecases/cambiar_password_asistente.dart';
import '../../domain/usecases/crear_asistente.dart';
import '../../domain/usecases/listar_asistentes.dart';
import '../../domain/usecases/modificar_asistente.dart';
import 'asistente_event.dart';
import 'asistente_state.dart';

class AsistenteBloc extends Bloc<AsistenteEvent, AsistenteState> {
  final ListarAsistentesUseCase listarAsistentesUseCase;
  final CrearAsistenteUseCase crearAsistenteUseCase;
  final ModificarAsistenteUseCase modificarAsistenteUseCase;
  final CambiarEstadoAsistenteUseCase cambiarEstadoAsistenteUseCase;
  final CambiarPasswordAsistenteUseCase cambiarPasswordAsistenteUseCase;

  AsistenteBloc({
    required this.listarAsistentesUseCase,
    required this.crearAsistenteUseCase,
    required this.modificarAsistenteUseCase,
    required this.cambiarEstadoAsistenteUseCase,
    required this.cambiarPasswordAsistenteUseCase,
  }) : super(AsistenteInitial()) {
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
      final asistentes = await listarAsistentesUseCase.execute();
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
      final resultado = await crearAsistenteUseCase.execute(
        nombre: event.nombre,
        apellido: event.apellido,
        email: event.email,
        ci: event.ci,
        ciudadId: event.ciudadId,
      );
      emit(
        AsistenteCreado(email: resultado.email, password: resultado.password),
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
      await modificarAsistenteUseCase.execute(
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
      await cambiarEstadoAsistenteUseCase.execute(event.id, event.estado);
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
      await cambiarPasswordAsistenteUseCase.execute(
        passwordActual: event.passwordActual,
        passwordNuevo: event.passwordNuevo,
      );
      emit(PasswordCambiado());
    } catch (e) {
      emit(AsistenteError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
