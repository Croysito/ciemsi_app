import 'package:equatable/equatable.dart';

abstract class RecetaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GuardarRecetaHistorialEvent extends RecetaEvent {
  final int historialId;
  final String texto;

  GuardarRecetaHistorialEvent({
    required this.historialId,
    required this.texto,
  });

  @override
  List<Object?> get props => [historialId, texto];
}
