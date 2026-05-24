import 'package:ciemsi_app/features/tratamientos/domain/entities/tratamiento_asignado.dart'
    as entidad;
import 'package:ciemsi_app/features/suministros/domain/entities/suministro.dart';
import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/tratamientos/domain/entities/tratamiento.dart';

abstract class TratamientoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TratamientoInitial extends TratamientoState {}

class TratamientoLoading extends TratamientoState {}

class TratamientosListados extends TratamientoState {
  final List<Tratamiento> tratamientos;
  TratamientosListados(this.tratamientos);
  @override
  List<Object?> get props => [tratamientos];
}

class TratamientoCreado extends TratamientoState {}

class TratamientoAsignadoExito extends TratamientoState {}

class SuministroAgregado extends TratamientoState {}

class TratamientoCompletado extends TratamientoState {}

class TratamientosAsignadosListados extends TratamientoState {
  final List<entidad.TratamientoAsignado> tratamientos;
  TratamientosAsignadosListados(this.tratamientos);
  @override
  List<Object?> get props => [tratamientos];
}

class RecetaGenerada extends TratamientoState {
  final Map<String, dynamic> receta;
  RecetaGenerada(this.receta);
  @override
  List<Object?> get props => [receta];
}

class MedicamentosCargados extends TratamientoState {
  final List<Suministro> medicamentos;
  MedicamentosCargados(this.medicamentos);
  @override
  List<Object?> get props => [medicamentos];
}

class TratamientoError extends TratamientoState {
  final String mensaje;
  TratamientoError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
