import 'package:equatable/equatable.dart';

abstract class ChatbotEvent extends Equatable {
  const ChatbotEvent();
  @override
  List<Object?> get props => [];
}

class EnviarMensajeEvent extends ChatbotEvent {
  final String mensaje;
  final bool mostrarMensajeEnChat;
  final bool mostrarRespuestaAsistente;

  const EnviarMensajeEvent(
    this.mensaje, {
    this.mostrarMensajeEnChat = true,
    this.mostrarRespuestaAsistente = true,
  });

  @override
  List<Object?> get props => [
    mensaje,
    mostrarMensajeEnChat,
    mostrarRespuestaAsistente,
  ];
}

class FinalizarConversacionEvent extends ChatbotEvent {
  const FinalizarConversacionEvent();
}

class VerificarEstadoEvent extends ChatbotEvent {
  const VerificarEstadoEvent();
}
