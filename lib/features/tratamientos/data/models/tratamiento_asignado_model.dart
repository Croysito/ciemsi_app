import 'package:ciemsi_app/features/tratamientos/domain/entities/tratamiento_asignado.dart';
import 'package:ciemsi_app/features/tratamientos/domain/entities/asignado_suministro.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/suministro.dart';
import 'tratamiento_model.dart';

class TratamientoAsignadoModel extends TratamientoAsignado {
  const TratamientoAsignadoModel({
    required super.id,
    required super.tratamiento,
    required super.cita,
    required super.precio,
    required super.estado,
    super.suministros,
    required super.createdAt,
  });

  factory TratamientoAsignadoModel.fromJson(Map<String, dynamic> json) {
    final suministros = (json['suministros'] as List? ?? [])
        .map(
          (s) => AsignadoSuministro(
            id: s['id'],
            tratamientoAsignadoId: s['tratamientoAsignadoId'] ?? 0,
            suministro: Suministro(
              id: s['suministro']['id'],
              nombreSuministro: s['suministro']['nombreSuministro'],
              unidadMedida: UnidadMedida.values.firstWhere(
                (e) => e.name == s['suministro']['unidadMedida'],
                orElse: () => UnidadMedida.UNIDAD,
              ),
              tipo: TipoSuministro.values.firstWhere(
                (e) => e.name == s['suministro']['tipo'],
                orElse: () => TipoSuministro.INSUMO,
              ),
              umbral: 5,
              estado: true,
            ),
            cantidad: double.tryParse(s['cantidad'].toString()) ?? 0,
            agregadoPor: s['agregadoPor'] ?? 'DOCTORA',
          ),
        )
        .toList();

    return TratamientoAsignadoModel(
      id: json['id'],
      tratamiento: TratamientoModel.fromJson(json['tratamiento']),
      cita: json['cita'],
      precio: double.tryParse(json['precio'].toString()) ?? 0,
      estado: json['estado'] ?? 'PENDIENTE',
      suministros: suministros,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
