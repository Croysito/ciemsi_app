import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'receta_event.dart';
import 'receta_state.dart';

class RecetaBloc extends Bloc<RecetaEvent, RecetaState> {
  final ApiClient _apiClient;

  RecetaBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientProvider.instance,
        super(RecetaInitial()) {
    on<GuardarRecetaHistorialEvent>(_onGuardarReceta);
  }

  Future<void> _onGuardarReceta(
    GuardarRecetaHistorialEvent event,
    Emitter<RecetaState> emit,
  ) async {
    emit(RecetaLoading());
    try {
      await _apiClient.dio.post(
        '/historial/${event.historialId}/notas',
        data: {'detalle': event.texto},
      );
      emit(RecetaGuardada());
    } catch (e) {
      emit(RecetaError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
