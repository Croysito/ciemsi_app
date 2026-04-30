import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/suministros/data/datasources/suministro_remote_datasource.dart';
import 'suministro_event.dart';
import 'suministro_state.dart';

class SuministroBloc extends Bloc<SuministroEvent, SuministroState> {
  final SuministroRemoteDatasource datasource;

  SuministroBloc()
    : datasource = SuministroRemoteDatasource(ApiClientProvider.instance),
      super(SuministroInitial()) {
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
      final suministros = await datasource.listarSuministros(tipo: event.tipo);
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
      await datasource.crearSuministro(
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
      final resultado = await datasource.obtenerInventario(event.ciudadId);
      emit(
        InventarioCargado(
          inventario: resultado['inventario'],
          stockBajo: resultado['stockBajo'],
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
      final resultado = await datasource.obtenerAlertas(event.ciudadId);
      emit(
        AlertasCargadas(
          stockBajo: resultado['stockBajo'] ?? [],
          proximosAVencer: resultado['proximosAVencer'] ?? [],
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
      await datasource.registrarCompra(
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
