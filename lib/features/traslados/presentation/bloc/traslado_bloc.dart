import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/listar_traslados.dart';
import '../../domain/usecases/crear_traslado.dart';
import '../../domain/usecases/confirmar_traslado.dart';
import '../../domain/usecases/devolver_traslado.dart';
import '../../domain/usecases/consultar_stock_traslado.dart';
import '../../domain/usecases/obtener_datos_creacion_traslado.dart';
import 'traslado_event.dart';
import 'traslado_state.dart';

class TrasladoBloc extends Bloc<TrasladoEvent, TrasladoState> {
  final ListarTrasladosUseCase listarUseCase;
  final CrearTrasladoUseCase crearUseCase;
  final ConfirmarTrasladoUseCase confirmarUseCase;
  final DevolverTrasladoUseCase devolverUseCase;
  final ObtenerDatosCreacionTrasladoUseCase obtenerDatosCreacionUseCase;
  final ConsultarStockTrasladoUseCase consultarStockUseCase;

  TrasladoBloc({
    required this.listarUseCase,
    required this.crearUseCase,
    required this.confirmarUseCase,
    required this.devolverUseCase,
    required this.obtenerDatosCreacionUseCase,
    required this.consultarStockUseCase,
  }) : super(TrasladoInitial()) {
    on<ListarTrasladosEvent>(_onListar);
    on<CargarDatosCreacionTrasladoEvent>(_onCargarDatosCreacion);
    on<ConsultarStockTrasladoEvent>(_onConsultarStock);
    on<CrearTrasladoEvent>(_onCrear);
    on<ConfirmarTrasladoEvent>(_onConfirmar);
    on<DevolverTrasladoEvent>(_onDevolver);
  }

  Future<void> _onListar(
    ListarTrasladosEvent event,
    Emitter<TrasladoState> emit,
  ) async {
    emit(TrasladoLoading());
    try {
      final traslados = await listarUseCase.execute(event.ciudadId);
      emit(TrasladosListados(traslados));
    } catch (e) {
      emit(TrasladoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarDatosCreacion(
    CargarDatosCreacionTrasladoEvent event,
    Emitter<TrasladoState> emit,
  ) async {
    emit(TrasladoDatosCreacionLoading());
    try {
      final datos = await obtenerDatosCreacionUseCase.execute(
        event.ciudadOrigenId,
      );
      emit(TrasladoDatosCreacionCargados(datos));
    } catch (e) {
      emit(TrasladoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onConsultarStock(
    ConsultarStockTrasladoEvent event,
    Emitter<TrasladoState> emit,
  ) async {
    emit(TrasladoStockLoading());
    try {
      final stock = await consultarStockUseCase.execute(
        tipo: event.tipo,
        itemId: event.itemId,
        ciudadOrigenId: event.ciudadOrigenId,
      );
      emit(TrasladoStockCargado(stock.disponible));
    } catch (e) {
      emit(TrasladoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCrear(
    CrearTrasladoEvent event,
    Emitter<TrasladoState> emit,
  ) async {
    emit(TrasladoLoading());
    try {
      await crearUseCase.execute(
        tipo: event.tipo,
        suministroId: event.suministroId,
        productoId: event.productoId,
        ciudadOrigenId: event.ciudadOrigenId,
        ciudadDestinoId: event.ciudadDestinoId,
        cantidad: event.cantidad,
      );
      emit(TrasladoOperacionExitosa(event.ciudadOrigenId));
    } catch (e) {
      emit(TrasladoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onConfirmar(
    ConfirmarTrasladoEvent event,
    Emitter<TrasladoState> emit,
  ) async {
    emit(TrasladoLoading());
    try {
      await confirmarUseCase.execute(event.id);
      emit(TrasladoOperacionExitosa(event.ciudadId));
    } catch (e) {
      emit(TrasladoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDevolver(
    DevolverTrasladoEvent event,
    Emitter<TrasladoState> emit,
  ) async {
    emit(TrasladoLoading());
    try {
      await devolverUseCase.execute(event.id);
      emit(TrasladoOperacionExitosa(event.ciudadId));
    } catch (e) {
      emit(TrasladoError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
