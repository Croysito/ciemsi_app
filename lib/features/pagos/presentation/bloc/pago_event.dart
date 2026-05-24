import 'package:equatable/equatable.dart';

abstract class PagoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ObtenerEstadoCuentaEvent extends PagoEvent {
  final int pacienteId;
  ObtenerEstadoCuentaEvent(this.pacienteId);

  @override
  List<Object?> get props => [pacienteId];
}

class RegistrarCobroDeudaEvent extends PagoEvent {
  final int deudaId;
  final int pacienteId;
  final int ciudadId;
  final double monto;
  final String metodo;
  final String? notas;

  RegistrarCobroDeudaEvent({
    required this.deudaId,
    required this.pacienteId,
    required this.ciudadId,
    required this.monto,
    required this.metodo,
    this.notas,
  });

  @override
  List<Object?> get props => [deudaId, monto, metodo];
}

class RegistrarVentaProductoEvent extends PagoEvent {
  final int pacienteId;
  final int ciudadId;
  final List<Map<String, dynamic>> items;
  final String metodo;
  final String? notas;

  RegistrarVentaProductoEvent({
    required this.pacienteId,
    required this.ciudadId,
    required this.items,
    required this.metodo,
    this.notas,
  });

  @override
  List<Object?> get props => [pacienteId, ciudadId, items, metodo];
}

class ListarProductosEvent extends PagoEvent {}

class ListarInventarioProductosEvent extends PagoEvent {
  final int ciudadId;

  ListarInventarioProductosEvent(this.ciudadId);

  @override
  List<Object?> get props => [ciudadId];
}

class CrearProductoEvent extends PagoEvent {
  final String nombre;
  final String? descripcion;
  final String unidadMedida;
  final double precioVenta;
  final int umbral;

  CrearProductoEvent({
    required this.nombre,
    this.descripcion,
    required this.unidadMedida,
    required this.precioVenta,
    required this.umbral,
  });

  @override
  List<Object?> get props => [nombre, unidadMedida, precioVenta, umbral];
}

class ModificarProductoEvent extends PagoEvent {
  final int id;
  final String nombre;
  final String? descripcion;
  final String unidadMedida;
  final double precioVenta;
  final int umbral;
  final bool estado;

  ModificarProductoEvent({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.unidadMedida,
    required this.precioVenta,
    required this.umbral,
    required this.estado,
  });

  @override
  List<Object?> get props => [id, nombre, precioVenta, estado];
}

class CambiarEstadoProductoEvent extends PagoEvent {
  final int id;
  CambiarEstadoProductoEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ListarComprasProductoEvent extends PagoEvent {
  final int? ciudadId;
  ListarComprasProductoEvent({this.ciudadId});

  @override
  List<Object?> get props => [ciudadId];
}

class RegistrarCompraProductoEvent extends PagoEvent {
  final int ciudadId;
  final String fecha;
  final List<Map<String, dynamic>> items;

  RegistrarCompraProductoEvent({
    required this.ciudadId,
    required this.fecha,
    required this.items,
  });

  @override
  List<Object?> get props => [ciudadId, fecha, items];
}

class CargarCiudadesPagoEvent extends PagoEvent {}

class CargarMiPerfilPacienteEvent extends PagoEvent {}

class CargarResumenDeudasEvent extends PagoEvent {}

class CargarPerfilCompletoEvent extends PagoEvent {}
