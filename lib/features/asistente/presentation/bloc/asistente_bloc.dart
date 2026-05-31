import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/asistente_datasource.dart';
import 'asistente_event.dart';
import 'asistente_state.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final AsistenteDatasource _datasource;
  AsistenteDatasource get datasource => _datasource;

  List<MensajeChat> _mensajes = [];

  ChatbotBloc(this._datasource) : super(ChatbotInicial()) {
    on<VerificarEstadoEvent>(_onVerificarEstado);
    on<EnviarMensajeEvent>(_onEnviarMensaje);
    on<FinalizarConversacionEvent>(_onFinalizar);
  }

  Future<void> _onVerificarEstado(
    VerificarEstadoEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    try {
      final data = await _datasource.obtenerEstado();
      emit(
        EstadoCargado(
          esNuevo: data['esNuevo'] as bool,
          perfil: PerfilPacienteAsistente.fromJson(
            data['perfil'] as Map<String, dynamic>? ?? {},
          ),
        ),
      );
    } catch (e) {
      final msg = e is DioException
          ? ApiClient.errorMessage(e, 'Error al verificar estado')
          : e.toString();
      emit(ChatbotError(mensajes: _mensajes, mensaje: msg));
    }
  }

  Future<void> _onEnviarMensaje(
    EnviarMensajeEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    if (event.mostrarMensajeEnChat) {
      _mensajes = [
        ..._mensajes,
        MensajeChat(contenido: event.mensaje, esUsuario: true),
      ];
    }
    emit(ChatbotEscribiendo(_mensajes));

    try {
      final resp = await _datasource.chat(nuevoMensaje: event.mensaje);

      final respuesta = _limpiarRespuestaAsistente(
        resp['respuesta'] as String? ?? '',
      );
      final listo = resp['listo'] as bool? ?? false;

      if (event.mostrarRespuestaAsistente && respuesta.isNotEmpty) {
        _mensajes = [
          ..._mensajes,
          MensajeChat(contenido: respuesta, esUsuario: false),
        ];
      }

      emit(MensajeRecibido(mensajes: _mensajes, listo: listo));
    } catch (e) {
      final msg = e is DioException
          ? ApiClient.errorMessage(e, 'Error al conectar con el asistente')
          : e.toString();
      emit(ChatbotError(mensajes: _mensajes, mensaje: msg));
    }
  }

  String _limpiarRespuestaAsistente(String respuesta) {
    return respuesta
        .replaceFirst(
          RegExp(
            r'^\s*(hola|buenos dias|buenos días|buenas tardes|buenas noches),?\s+[^.!?\n]{1,50}[.!?]?\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  Future<void> _onFinalizar(
    FinalizarConversacionEvent event,
    Emitter<ChatbotState> emit,
  ) async {
    try {
      await _datasource.finalizar();
      emit(ConversacionFinalizada());
    } catch (e) {
      final msg = e is DioException
          ? ApiClient.errorMessage(e, 'Error al guardar la historia clínica')
          : e.toString();
      emit(ChatbotError(mensajes: _mensajes, mensaje: msg));
    }
  }
}
