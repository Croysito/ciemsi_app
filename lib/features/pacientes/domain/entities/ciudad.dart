import 'package:equatable/equatable.dart';

class Ciudad extends Equatable {
  final int id;
  final String nombreCiudad;

  const Ciudad({required this.id, required this.nombreCiudad});

  @override
  List<Object> get props => [id, nombreCiudad];
}
