import 'package:equatable/equatable.dart';
import 'nota_evolucion.dart';

class HistorialClinico extends Equatable {
  final int id;
  final DateTime fecha;
  final int pacienteId;
  final List<NotaEvolucion> notas;

  const HistorialClinico({
    required this.id,
    required this.fecha,
    required this.pacienteId,
    this.notas = const [],
  });

  @override
  List<Object> get props => [id, fecha, pacienteId, notas];
}
