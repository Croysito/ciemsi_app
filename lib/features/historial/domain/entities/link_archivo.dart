import 'package:equatable/equatable.dart';

enum TipoLink { IMAGEN, VIDEO, DRIVE }

class LinkArchivo extends Equatable {
  final int id;
  final String nombre;
  final String link;
  final TipoLink tipo;
  final int notaId;

  const LinkArchivo({
    required this.id,
    required this.nombre,
    required this.link,
    required this.tipo,
    required this.notaId,
  });

  @override
  List<Object> get props => [id, nombre, link, tipo, notaId];
}
