import 'package:equatable/equatable.dart';
import '../../domain/entities/ingreso.dart';
import '../../domain/entities/estado_cuenta.dart';
import '../../domain/entities/producto.dart';
import '../../domain/entities/producto_inventario_item.dart';
import '../../domain/entities/compra_producto.dart';

abstract class PagoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PagoInitial extends PagoState {}

class PagoLoading extends PagoState {}

class EstadoCuentaObtenido extends PagoState {
  final EstadoCuenta estadoCuenta;
  EstadoCuentaObtenido(this.estadoCuenta);

  @override
  List<Object?> get props => [estadoCuenta];
}

class IngresoRegistrado extends PagoState {
  final Ingreso ingreso;
  IngresoRegistrado(this.ingreso);

  @override
  List<Object?> get props => [ingreso];
}

class ProductosListados extends PagoState {
  final List<Producto> productos;
  ProductosListados(this.productos);

  @override
  List<Object?> get props => [productos];
}

class InventarioProductosListado extends PagoState {
  final List<ProductoInventarioItem> items;

  InventarioProductosListado(this.items);

  @override
  List<Object?> get props => [items];
}

class ProductoOperacionExitosa extends PagoState {
  final Producto? producto;
  ProductoOperacionExitosa({this.producto});

  @override
  List<Object?> get props => [producto];
}

class ComprasProductoListadas extends PagoState {
  final List<CompraProducto> compras;
  ComprasProductoListadas(this.compras);

  @override
  List<Object?> get props => [compras];
}

class CompraProductoRegistrada extends PagoState {}

class CiudadesPagoCargadas extends PagoState {
  final List<Map<String, dynamic>> ciudades;
  CiudadesPagoCargadas(this.ciudades);

  @override
  List<Object?> get props => [ciudades];
}

class MiPerfilPacienteCargado extends PagoState {
  final int pacienteId;
  MiPerfilPacienteCargado(this.pacienteId);

  @override
  List<Object?> get props => [pacienteId];
}

class ResumenDeudasCargado extends PagoState {
  final Map<int, double> deudas;
  ResumenDeudasCargado(this.deudas);

  @override
  List<Object?> get props => [deudas];
}

class PerfilCompletoObtenido extends PagoState {
  final int pacienteId;
  final String ci;
  final String telefono;

  PerfilCompletoObtenido({
    required this.pacienteId,
    required this.ci,
    required this.telefono,
  });

  @override
  List<Object?> get props => [pacienteId, ci, telefono];
}

class PagoError extends PagoState {
  final String mensaje;
  PagoError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
