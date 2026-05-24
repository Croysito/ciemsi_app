import 'package:equatable/equatable.dart';

class TrasladoCiudadOption extends Equatable {
  final int id;
  final String nombre;

  const TrasladoCiudadOption({required this.id, required this.nombre});

  @override
  List<Object?> get props => [id, nombre];
}
