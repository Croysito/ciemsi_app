import '../../domain/entities/traslado.dart';

class TrasladoModel extends Traslado {
  const TrasladoModel({
    required super.id,
    required super.tipo,
    super.suministroId,
    super.nombreSuministro,
    super.productoId,
    super.nombreProducto,
    required super.ciudadOrigenId,
    required super.nombreCiudadOrigen,
    required super.ciudadDestinoId,
    required super.nombreCiudadDestino,
    required super.cantidad,
    required super.estado,
    required super.usuarioId,
    required super.nombreUsuario,
    required super.fecha,
    super.fechaConfirmacion,
    super.fechaDevolucion,
  });

  factory TrasladoModel.fromJson(Map<String, dynamic> json) {
    return TrasladoModel(
      id:                  int.tryParse(json['id'].toString()) ?? 0,
      tipo:                json['tipo'] ?? '',
      suministroId:        json['suministro_id'] != null
                             ? int.tryParse(json['suministro_id'].toString())
                             : null,
      nombreSuministro:    json['nombre_suministro'],
      productoId:          json['producto_id'] != null
                             ? int.tryParse(json['producto_id'].toString())
                             : null,
      nombreProducto:      json['nombre_producto'],
      ciudadOrigenId:      int.tryParse(json['ciudad_origen_id'].toString()) ?? 0,
      nombreCiudadOrigen:  json['nombre_ciudad_origen'] ?? '',
      ciudadDestinoId:     int.tryParse(json['ciudad_destino_id'].toString()) ?? 0,
      nombreCiudadDestino: json['nombre_ciudad_destino'] ?? '',
      cantidad:            double.tryParse(json['cantidad'].toString()) ?? 0,
      estado:              json['estado'] ?? 'PENDIENTE',
      usuarioId:           int.tryParse(json['usuario_id'].toString()) ?? 0,
      nombreUsuario:       json['nombre_usuario'] ?? '',
      fecha:               DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now(),
      fechaConfirmacion:   json['fecha_confirmacion'] != null
                             ? DateTime.tryParse(json['fecha_confirmacion'].toString())
                             : null,
      fechaDevolucion:     json['fecha_devolucion'] != null
                             ? DateTime.tryParse(json['fecha_devolucion'].toString())
                             : null,
    );
  }
}
