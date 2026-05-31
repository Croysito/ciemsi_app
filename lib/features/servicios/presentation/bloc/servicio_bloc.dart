import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/listar_servicios.dart';
import '../../domain/usecases/crear_servicio.dart';
import '../../domain/usecases/modificar_servicio.dart';
import 'servicio_event.dart';
import 'servicio_state.dart';

class ServicioBloc extends Bloc<ServicioEvent, ServicioState> {
  final ListarServiciosUseCase _listar;
  final CrearServicioUseCase _crear;
  final ModificarServicioUseCase _modificar;

  ServicioBloc({
    required ListarServiciosUseCase listarUseCase,
    required CrearServicioUseCase crearUseCase,
    required ModificarServicioUseCase modificarUseCase,
  })  : _listar = listarUseCase,
        _crear = crearUseCase,
        _modificar = modificarUseCase,
        super(ServicioInitial()) {
    on<CargarServiciosEvent>(_onCargar);
    on<CrearServicioEvent>(_onCrear);
    on<ModificarServicioEvent>(_onModificar);
  }

  Future<void> _onCargar(
    CargarServiciosEvent event,
    Emitter<ServicioState> emit,
  ) async {
    emit(ServicioLoading());
    try {
      final servicios = await _listar();
      emit(ServiciosCargados(servicios));
    } catch (e) {
      emit(ServicioError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCrear(
    CrearServicioEvent event,
    Emitter<ServicioState> emit,
  ) async {
    emit(ServicioLoading());
    try {
      await _crear(event.datos);
      emit(ServicioOperacionExitosa());
    } catch (e) {
      emit(ServicioError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onModificar(
    ModificarServicioEvent event,
    Emitter<ServicioState> emit,
  ) async {
    emit(ServicioLoading());
    try {
      await _modificar(event.servicio.id, event.datos);
      emit(ServicioOperacionExitosa());
    } catch (e) {
      emit(ServicioError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
