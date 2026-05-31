import 'package:equatable/equatable.dart';

class MensajeChat extends Equatable {
  final String contenido;
  final bool esUsuario;
  const MensajeChat({required this.contenido, required this.esUsuario});
  @override
  List<Object?> get props => [contenido, esUsuario];
}

abstract class ChatbotState extends Equatable {
  const ChatbotState();
  @override
  List<Object?> get props => [];
}

class ChatbotInicial extends ChatbotState {}

class ChatbotEscribiendo extends ChatbotState {
  final List<MensajeChat> mensajes;
  const ChatbotEscribiendo(this.mensajes);
  @override
  List<Object?> get props => [mensajes];
}

class MensajeRecibido extends ChatbotState {
  final List<MensajeChat> mensajes;
  final bool listo;
  const MensajeRecibido({required this.mensajes, required this.listo});
  @override
  List<Object?> get props => [mensajes, listo];
}

class PerfilPacienteAsistente {
  final String? nombreCompleto;
  final String? ci;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final int? edad;

  const PerfilPacienteAsistente({
    this.nombreCompleto,
    this.ci,
    this.telefono,
    this.fechaNacimiento,
    this.edad,
  });

  factory PerfilPacienteAsistente.fromJson(Map<String, dynamic> json) {
    return PerfilPacienteAsistente(
      nombreCompleto: json['nombreCompleto'] as String?,
      ci:             json['ci']             as String?,
      telefono:       json['telefono']       as String?,
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.tryParse(json['fechaNacimiento'] as String)
          : null,
      edad: json['edad'] as int?,
    );
  }
}

class EstadoCargado extends ChatbotState {
  final bool esNuevo;
  final PerfilPacienteAsistente perfil;
  const EstadoCargado({required this.esNuevo, required this.perfil});
  @override
  List<Object?> get props => [esNuevo];
}

class ConversacionFinalizada extends ChatbotState {}

class ChatbotError extends ChatbotState {
  final List<MensajeChat> mensajes;
  final String mensaje;
  const ChatbotError({required this.mensajes, required this.mensaje});
  @override
  List<Object?> get props => [mensajes, mensaje];
}
