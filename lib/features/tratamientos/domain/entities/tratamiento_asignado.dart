import 'package:equatable/equatable.dart';
import 'tratamiento.dart';
import 'asignado_suministro.dart';

class TratamientoAsignado extends Equatable {
  final int id;
  final Tratamiento tratamiento;
  final Map<String, dynamic> cita;
  final double precio;
  final String estado;
  final List<AsignadoSuministro> suministros;
  final DateTime createdAt;

  const TratamientoAsignado({
    required this.id,
    required this.tratamiento,
    required this.cita,
    required this.precio,
    required this.estado,
    this.suministros = const [],
    required this.createdAt,
  });

  String get estadoCita => cita['estado'] ?? '';
  String get ciudadNombre => cita['ciudad']?['nombreCiudad'] ?? '';
  int get ciudadId => cita['ciudad']?['id'] ?? 0;

  @override
  List<Object?> get props => [id, tratamiento, cita, precio, estado];
}
