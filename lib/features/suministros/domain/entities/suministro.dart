import 'package:equatable/equatable.dart';

enum TipoSuministro { MEDICAMENTO, INSUMO, MATERIAL }

enum UnidadMedida { UNIDAD, CAJA, FRASCO, AMPOLLA, LITRO, GRAMO, MILILITRO }

class Suministro extends Equatable {
  final int id;
  final String nombreSuministro;
  final UnidadMedida unidadMedida;
  final String? marca;
  final TipoSuministro tipo;
  final int umbral;
  final bool estado;

  const Suministro({
    required this.id,
    required this.nombreSuministro,
    required this.unidadMedida,
    this.marca,
    required this.tipo,
    required this.umbral,
    required this.estado,
  });

  @override
  List<Object?> get props => [
    id,
    nombreSuministro,
    unidadMedida,
    tipo,
    umbral,
    estado,
  ];
}
