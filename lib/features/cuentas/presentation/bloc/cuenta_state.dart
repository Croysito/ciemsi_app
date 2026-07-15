import 'package:equatable/equatable.dart';
import '../../domain/entities/resumen_cuenta.dart';
import '../../domain/entities/resumen_mensual_cuenta.dart';
import '../../domain/entities/historial_movimiento.dart';

abstract class CuentaState extends Equatable {
  const CuentaState();
  @override
  List<Object?> get props => [];
}

class CuentaInitial extends CuentaState {}

class CuentaLoading extends CuentaState {}

class ResumenCuentasCargado extends CuentaState {
  final List<ResumenCuenta> resumenes;
  const ResumenCuentasCargado(this.resumenes);
  @override
  List<Object?> get props => [resumenes];
}

class HistorialCargado extends CuentaState {
  final List<HistorialMovimiento> movimientos;
  const HistorialCargado(this.movimientos);
  @override
  List<Object?> get props => [movimientos];
}

class ResumenMensualCargado extends CuentaState {
  final ResumenMensualCuenta resumen;
  const ResumenMensualCargado(this.resumen);
  @override
  List<Object?> get props => [resumen];
}

class SaldoInicialCargado extends CuentaState {
  final double caja;
  final double banco;
  const SaldoInicialCargado({required this.caja, required this.banco});
  @override
  List<Object?> get props => [caja, banco];
}

class SaldoInicialActualizado extends CuentaState {}

class MovimientoExtraRegistrado extends CuentaState {}

class MovimientoExtraEliminado extends CuentaState {}

class TraspasoRegistrado extends CuentaState {}

class TraspasoEliminado extends CuentaState {}

class CuentaError extends CuentaState {
  final String mensaje;
  const CuentaError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
