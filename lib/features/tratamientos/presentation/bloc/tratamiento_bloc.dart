import 'package:ciemsi_app/features/tratamientos/domain/entities/tratamiento_asignado.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/tratamientos/data/datasources/tratamiento_remote_datasource.dart';
import 'tratamiento_event.dart';
import 'tratamiento_state.dart';

class TratamientoBloc extends Bloc<TratamientoEvent, TratamientoState> {
  final TratamientoRemoteDatasource datasource;

  TratamientoBloc()
    : datasource = TratamientoRemoteDatasource(ApiClientProvider.instance),
      super(TratamientoInitial()) {
    on<ListarTratamientosEvent>(_onListar);
    on<CrearTratamientoEvent>(_onCrear);
    on<AsignarTratamientoEvent>(_onAsignar);
    on<ListarAsignadosEvent>(_onListarAsignados);
    on<ListarAsignadosByCitaEvent>(_onListarAsignadosByCita);
    on<AgregarSuministroEvent>(_onAgregarSuministro);
    on<AgregarMultiplesSuministrosEvent>(_onAgregarMultiples);
    on<CompletarTratamientoEvent>(_onCompletar);
    on<GenerarRecetaEvent>(_onGenerarReceta);
  }

  Future<void> _onListar(
    ListarTratamientosEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      final tratamientos = await datasource.listarTratamientos();
      emit(TratamientosListados(tratamientos));
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCrear(
    CrearTratamientoEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      await datasource.crearTratamiento(
        nombreTratamiento: event.nombreTratamiento,
        detalle: event.detalle,
        precioBase: event.precioBase,
      );
      emit(TratamientoCreado());
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAsignar(
    AsignarTratamientoEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      await datasource.asignarTratamiento(
        tratamientoId: event.tratamientoId,
        citaId: event.citaId,
        precio: event.precio,
        medicamentos: event.medicamentos,
      );
      emit(TratamientoAsignadoExito());
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onListarAsignados(
    ListarAsignadosEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      final List<TratamientoAsignado> tratamientos = await datasource
          .listarAsignados();
      emit(TratamientosAsignadosListados(tratamientos));
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onListarAsignadosByCita(
    ListarAsignadosByCitaEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      final List<TratamientoAsignado> tratamientos = await datasource
          .listarAsignadosByCita(event.citaId);
      emit(TratamientosAsignadosListados(tratamientos));
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAgregarSuministro(
    AgregarSuministroEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      await datasource.agregarSuministro(
        tratamientoAsignadoId: event.tratamientoAsignadoId,
        suministroId: event.suministroId,
        cantidad: event.cantidad,
      );
      emit(SuministroAgregado());
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAgregarMultiples(
    AgregarMultiplesSuministrosEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      for (final item in event.items) {
        await datasource.agregarSuministro(
          tratamientoAsignadoId: event.tratamientoAsignadoId,
          suministroId: item['suministroId'] as int,
          cantidad: item['cantidad'] as int,
        );
      }
      emit(SuministroAgregado());
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCompletar(
    CompletarTratamientoEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      await datasource.completarTratamiento(event.id);
      emit(TratamientoCompletado());
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGenerarReceta(
    GenerarRecetaEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      final receta = await datasource.generarReceta(
        citaId: event.citaId,
        detalle: event.detalle,
      );
      emit(RecetaGenerada(receta));
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
