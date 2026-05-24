import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/agenda/data/models/agenda_model.dart';
import 'package:ciemsi_app/features/pacientes/data/models/ciudad_model.dart';
import 'agenda_event.dart';
import 'agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc() : super(AgendaInitial()) {
    on<CargarAgendasEvent>(_onCargarAgendas);
    on<CambiarEstadoAgendaEvent>(_onCambiarEstado);
    on<EliminarAgendaEvent>(_onEliminar);
    on<CargarCiudadesAgendaEvent>(_onCargarCiudades);
    on<CrearAgendaEvent>(_onCrear);
  }

  Future<void> _onCargarAgendas(
    CargarAgendasEvent event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      final response = await ApiClientProvider.instance.dio.get('/agenda');
      debugPrint('[AgendaBloc] Raw response: ${response.data}');

      final lista = response.data;
      if (lista is! List) {
        emit(AgendaError('Respuesta inesperada del servidor: ${lista.runtimeType}'));
        return;
      }

      final agendas = <AgendaModel>[];
      for (final item in lista) {
        try {
          agendas.add(AgendaModel.fromJson(item));
        } catch (e) {
          debugPrint('[AgendaBloc] Error parseando item: $item → $e');
        }
      }

      debugPrint(
        '[AgendaBloc] Total: ${agendas.length}, '
        'activas: ${agendas.where((a) => a.estado).length}, '
        'inactivas: ${agendas.where((a) => !a.estado).length}',
      );
      emit(AgendasCargadas(agendas));
    } catch (e) {
      debugPrint('[AgendaBloc] Error cargando: $e');
      emit(AgendaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCambiarEstado(
    CambiarEstadoAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      debugPrint(
        '[AgendaBloc] PATCH /agenda/${event.id}/estado → estado=${event.estado}',
      );
      final res = await ApiClientProvider.instance.dio.patch(
        '/agenda/${event.id}/estado',
        data: {'estado': event.estado},
      );
      debugPrint('[AgendaBloc] PATCH ok: ${res.statusCode} ${res.data}');
      emit(AgendaOperacionExitosa());
    } catch (e) {
      debugPrint('[AgendaBloc] PATCH error: $e');
      emit(AgendaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onEliminar(
    EliminarAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      await ApiClientProvider.instance.dio.delete('/agenda/${event.id}');
      emit(AgendaOperacionExitosa());
    } catch (e) {
      emit(AgendaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarCiudades(
    CargarCiudadesAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      final response = await ApiClientProvider.instance.dio.get('/ciudades');
      final lista = (response.data as List)
          .map((c) => CiudadModel(id: c['id'], nombreCiudad: c['nombreCiudad']))
          .toList();
      emit(CiudadesAgendaCargadas(lista));
    } catch (e) {
      debugPrint('[AgendaBloc] Error cargando ciudades: $e');
      emit(AgendaError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCrear(
    CrearAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      await ApiClientProvider.instance.dio.post('/agenda', data: event.datos);
      emit(AgendaOperacionExitosa());
    } catch (e) {
      emit(AgendaError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
