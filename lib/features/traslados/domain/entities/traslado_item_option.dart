import 'package:equatable/equatable.dart';

class TrasladoItemOption extends Equatable {
  final int id;
  final String nombre;

  const TrasladoItemOption({required this.id, required this.nombre});

  @override
  List<Object?> get props => [id, nombre];
}
