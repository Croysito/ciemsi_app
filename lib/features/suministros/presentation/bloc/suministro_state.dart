import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/suministro.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/inventario_item.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/inventario_comparado.dart';

abstract class SuministroState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SuministroInitial extends SuministroState {}

class SuministroLoading extends SuministroState {}

class SuministrosListados extends SuministroState {
  final List<Suministro> suministros;
  SuministrosListados(this.suministros);
  @override
  List<Object?> get props => [suministros];
}

class SuministroCreado extends SuministroState {}

class InventarioCargado extends SuministroState {
  final List<InventarioItem> inventario;
  final List<InventarioItem> stockBajo;
  InventarioCargado({required this.inventario, required this.stockBajo});
  @override
  List<Object?> get props => [inventario, stockBajo];
}

class AlertasCargadas extends SuministroState {
  final List<dynamic> stockBajo;
  final List<dynamic> proximosAVencer;
  AlertasCargadas({required this.stockBajo, required this.proximosAVencer});
  @override
  List<Object?> get props => [stockBajo, proximosAVencer];
}

class CatalogoCargado extends SuministroState {
  final List<Suministro> suministros;
  CatalogoCargado(this.suministros);
  @override
  List<Object?> get props => [suministros];
}

class CompraRegistrada extends SuministroState {}

/// P4 · Resultado del modo Comparar — el estado de celda se calcula en la
/// UI a partir de `saldo`/`umbral`, nunca del `stockBajo` del backend, así
/// el saldo 0 se puede distinguir de una alerta real (regla del cero).
class InventarioComparadoCargado extends SuministroState {
  final InventarioComparado datos;
  InventarioComparadoCargado(this.datos);
  @override
  List<Object?> get props => [datos];
}

class SuministroError extends SuministroState {
  final String mensaje;
  SuministroError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
