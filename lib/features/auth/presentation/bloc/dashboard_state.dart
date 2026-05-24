import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardCargado extends DashboardState {
  final List<Map<String, dynamic>> citasHoy;
  final List<Map<String, dynamic>> cumpleaneros;
  final List<Map<String, dynamic>> alertasStock;

  DashboardCargado({
    required this.citasHoy,
    required this.cumpleaneros,
    required this.alertasStock,
  });

  @override
  List<Object?> get props => [citasHoy, cumpleaneros, alertasStock];
}

class DashboardError extends DashboardState {
  final String mensaje;
  DashboardError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
