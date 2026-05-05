import 'package:ciemsi_app/features/tratamientos/domain/entities/tratamiento.dart';
import 'package:ciemsi_app/features/tratamientos/domain/entities/medicamento_base.dart';

class TratamientoModel extends Tratamiento {
  const TratamientoModel({
    required super.id,
    required super.nombreTratamiento,
    super.detalle,
    required super.precioBase,
    super.medicamentosBase,
  });

  factory TratamientoModel.fromJson(Map<String, dynamic> json) {
    return TratamientoModel(
      id: json['id'],
      nombreTratamiento: json['nombreTratamiento'],
      detalle: json['detalle'],
      precioBase: double.tryParse(json['precioBase'].toString()) ?? 0,
      medicamentosBase: (json['medicamentosBase'] as List? ?? [])
          .map((m) => MedicamentoBase.fromJson(m))
          .toList(),
    );
  }
}
