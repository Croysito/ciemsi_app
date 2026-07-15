import 'package:equatable/equatable.dart';

abstract class CuentaEvent extends Equatable {
  const CuentaEvent();
  @override
  List<Object?> get props => [];
}

class CargarResumenCuentasEvent extends CuentaEvent {
  final int? ciudadId;
  const CargarResumenCuentasEvent({this.ciudadId});
  @override
  List<Object?> get props => [ciudadId];
}

class CargarHistorialEvent extends CuentaEvent {
  final int ciudadId;
  final String? fechaDesde;
  final String? fechaHasta;
  final String? tipo;
  const CargarHistorialEvent({
    required this.ciudadId,
    this.fechaDesde,
    this.fechaHasta,
    this.tipo,
  });
  @override
  List<Object?> get props => [ciudadId, fechaDesde, fechaHasta, tipo];
}

class CargarResumenMensualEvent extends CuentaEvent {
  final int ciudadId;
  final int anio;
  final int mes;
  const CargarResumenMensualEvent({
    required this.ciudadId,
    required this.anio,
    required this.mes,
  });
  @override
  List<Object?> get props => [ciudadId, anio, mes];
}

class CargarSaldoInicialEvent extends CuentaEvent {
  final int ciudadId;
  const CargarSaldoInicialEvent(this.ciudadId);
  @override
  List<Object?> get props => [ciudadId];
}

class SetSaldoInicialEvent extends CuentaEvent {
  final int ciudadId;
  final String tipo;
  final double monto;
  const SetSaldoInicialEvent({
    required this.ciudadId,
    required this.tipo,
    required this.monto,
  });
  @override
  List<Object?> get props => [ciudadId, tipo, monto];
}

class RegistrarMovimientoExtraEvent extends CuentaEvent {
  final String tipo;
  final String categoria;
  final String? descripcion;
  final double monto;
  final String metodo;
  final int ciudadId;
  const RegistrarMovimientoExtraEvent({
    required this.tipo,
    required this.categoria,
    this.descripcion,
    required this.monto,
    required this.metodo,
    required this.ciudadId,
  });
  @override
  List<Object?> get props => [tipo, categoria, monto, metodo, ciudadId];
}

class EliminarMovimientoExtraEvent extends CuentaEvent {
  final int id;
  const EliminarMovimientoExtraEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class RegistrarTraspasoEvent extends CuentaEvent {
  final String tipo; // 'efectivo_a_banco' | 'banco_a_efectivo'
  final double monto;
  final String? descripcion;
  final int ciudadId;
  const RegistrarTraspasoEvent({
    required this.tipo,
    required this.monto,
    this.descripcion,
    required this.ciudadId,
  });
  @override
  List<Object?> get props => [tipo, monto, ciudadId];
}

class EliminarTraspasoEvent extends CuentaEvent {
  final int id;
  const EliminarTraspasoEvent(this.id);
  @override
  List<Object?> get props => [id];
}
