import 'package:equatable/equatable.dart';

abstract class RecetaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecetaInitial extends RecetaState {}

class RecetaLoading extends RecetaState {}

class RecetaGuardada extends RecetaState {}

class RecetaError extends RecetaState {
  final String mensaje;
  RecetaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
