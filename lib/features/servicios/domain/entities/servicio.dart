import 'package:equatable/equatable.dart';

class Servicio extends Equatable {
  final int id;
  final String nombreServicio;
  final int tiempoMin;
  final bool estado;
  final List<String> roles;

  const Servicio({
    required this.id,
    required this.nombreServicio,
    required this.tiempoMin,
    required this.estado,
    this.roles = const [],
  });

  @override
  List<Object?> get props => [id, nombreServicio, tiempoMin, estado, roles];
}
