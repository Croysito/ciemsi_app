import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CargarDashboardEvent extends DashboardEvent {
  final int? ciudadId;
  CargarDashboardEvent({this.ciudadId});

  @override
  List<Object?> get props => [ciudadId];
}
