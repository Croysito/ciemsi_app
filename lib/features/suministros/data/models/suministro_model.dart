import 'package:ciemsi_app/features/suministros/domain/entities/suministro.dart';

class SuministroModel extends Suministro {
  const SuministroModel({
    required super.id,
    required super.nombreSuministro,
    required super.unidadMedida,
    super.marca,
    required super.tipo,
    required super.umbral,
    required super.estado,
  });

  factory SuministroModel.fromJson(Map<String, dynamic> json) {
    return SuministroModel(
      id: json['id'],
      nombreSuministro: json['nombreSuministro'],
      unidadMedida: UnidadMedida.values.firstWhere(
        (e) => e.name == json['unidadMedida'],
        orElse: () => UnidadMedida.UNIDAD,
      ),
      marca: json['marca'],
      tipo: TipoSuministro.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoSuministro.INSUMO,
      ),
      umbral: json['umbral'] ?? 5,
      estado: json['estado'] ?? true,
    );
  }
}
