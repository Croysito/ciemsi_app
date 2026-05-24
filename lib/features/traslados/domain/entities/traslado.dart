import 'package:equatable/equatable.dart';

class Traslado extends Equatable {
  final int id;
  final String tipo;
  final int? suministroId;
  final String? nombreSuministro;
  final int? productoId;
  final String? nombreProducto;
  final int ciudadOrigenId;
  final String nombreCiudadOrigen;
  final int ciudadDestinoId;
  final String nombreCiudadDestino;
  final double cantidad;
  final String estado;
  final int usuarioId;
  final String nombreUsuario;
  final DateTime fecha;
  final DateTime? fechaConfirmacion;
  final DateTime? fechaDevolucion;

  const Traslado({
    required this.id,
    required this.tipo,
    this.suministroId,
    this.nombreSuministro,
    this.productoId,
    this.nombreProducto,
    required this.ciudadOrigenId,
    required this.nombreCiudadOrigen,
    required this.ciudadDestinoId,
    required this.nombreCiudadDestino,
    required this.cantidad,
    required this.estado,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.fecha,
    this.fechaConfirmacion,
    this.fechaDevolucion,
  });

  String get nombreItem => nombreSuministro ?? nombreProducto ?? '';

  bool get isPendiente  => estado == 'PENDIENTE';
  bool get isCompletado => estado == 'COMPLETADO';
  bool get isDevuelto   => estado == 'DEVUELTO';

  @override
  List<Object?> get props => [id, estado];
}
