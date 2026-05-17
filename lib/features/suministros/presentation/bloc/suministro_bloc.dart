import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/crear_suministro.dart';
import '../../domain/usecases/listar_suministros.dart';
import '../../domain/usecases/obtener_alertas_suministro.dart';
import '../../domain/usecases/obtener_inventario.dart';
import '../../domain/usecases/registrar_compra.dart';
import 'suministro_event.dart';
import 'suministro_state.dart';

class SuministroBloc extends Bloc<SuministroEvent, SuministroState> {
  final ListarSuministrosUseCase listarSuministrosUseCase;
  final CrearSuministroUseCase crearSuministroUseCase;
  final ObtenerInventarioUseCase obtenerInventarioUseCase;
  final ObtenerAlertasSuministroUseCase obtenerAlertasSuministroUseCase;
  final RegistrarCompraUseCase registrarCompraUseCase;

  SuministroBloc({
    required this.listarSuministrosUseCase,
    required this.crearSuministroUseCase,
    required this.obtenerInventarioUseCase,
    required this.obtenerAlertasSuministroUseCase,
    required this.registrarCompraUseCase,
  }) : super(SuministroInitial()) {
    on<ListarSuministrosEvent>(_onListar);
    on<CrearSuministroEvent>(_onCrear);
    on<ObtenerInventarioEvent>(_onInventario);
    on<ObtenerAlertasEvent>(_onAlertas);
    on<RegistrarCompraEvent>(_onCompra);
  }

  Future<void> _onListar(
    ListarSuministrosEvent event,
    Emitter<SuministroState> emit,
  ) async {
    emit(SuministroLoading());
    try {
      final suministros = await listarSuministrosUseCase.execute(
        tipo: event.tipo,
      );
      emit(SuministrosListados(suministros));
    } catch (e) {
      emit(SuministroError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCrear(
    CrearSuministroEvent event,
    Emitter<SuministroState> emit,
  ) async {
    emit(SuministroLoading());
    try {
      await crearSuministroUseCase.execute(
        nombreSuministro: event.nombreSuministro,
        unidadMedida: event.unidadMedida,
        marca: event.marca,
        tipo: event.tipo,
        umbral: event.umbral,
      );
      emit(SuministroCreado());
    } catch (e) {
      emit(SuministroError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onInventario(
    ObtenerInventarioEvent event,
    Emitter<SuministroState> emit,
  ) async {
    emit(SuministroLoading());
    try {
      final resultado = await obtenerInventarioUseCase.execute(event.ciudadId);
      emit(
        InventarioCargado(
          inventario: resultado.inventario,
          stockBajo: resultado.stockBajo,
        ),
      );
    } catch (e) {
      emit(SuministroError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAlertas(
    ObtenerAlertasEvent event,
    Emitter<SuministroState> emit,
  ) async {
    emit(SuministroLoading());
    try {
      final resultado = await obtenerAlertasSuministroUseCase.execute(
        event.ciudadId,
      );
      emit(
        AlertasCargadas(
          stockBajo: resultado.stockBajo,
          proximosAVencer: resultado.proximosAVencer,
        ),
      );
    } catch (e) {
      emit(SuministroError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCompra(
    RegistrarCompraEvent event,
    Emitter<SuministroState> emit,
  ) async {
    emit(SuministroLoading());
    try {
      await registrarCompraUseCase.execute(
        ciudadId: event.ciudadId,
        items: event.items,
        fecha: event.fecha,
      );
      emit(CompraRegistrada());
    } catch (e) {
      emit(SuministroError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
