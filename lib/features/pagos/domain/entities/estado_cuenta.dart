import 'package:equatable/equatable.dart';
import 'ingreso.dart';
import 'deuda.dart';

class EstadoCuenta extends Equatable {
  final List<Deuda> deudas;
  final List<Ingreso> ingresos;
  final double totalDeuda;
  final double totalCobrado;
  final double totalPendiente;

  const EstadoCuenta({
    required this.deudas,
    required this.ingresos,
    required this.totalDeuda,
    required this.totalCobrado,
    required this.totalPendiente,
  });

  @override
  List<Object?> get props => [deudas, ingresos, totalDeuda, totalCobrado, totalPendiente];
}
