import 'package:equatable/equatable.dart';
import 'link_archivo.dart';

class NotaEvolucion extends Equatable {
  final int id;
  final DateTime fecha;
  final String detalle;
  final int historialId;
  final List<LinkArchivo> links;
  final DateTime? editadoEn;

  const NotaEvolucion({
    required this.id,
    required this.fecha,
    required this.detalle,
    required this.historialId,
    this.links = const [],
    this.editadoEn,
  });

  @override
  List<Object?> get props => [id, fecha, detalle, historialId, links, editadoEn];
}
