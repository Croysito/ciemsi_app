import 'package:ciemsi_app/features/tratamientos/domain/entities/tratamiento.dart';

class TratamientoModel extends Tratamiento {
  const TratamientoModel({
    required super.id,
    required super.nombreTratamiento,
    super.detalle,
    required super.precioBase,
  });

  factory TratamientoModel.fromJson(Map<String, dynamic> json) {
    return TratamientoModel(
      id: json['id'],
      nombreTratamiento: json['nombreTratamiento'],
      detalle: json['detalle'],
      precioBase: double.tryParse(json['precioBase'].toString()) ?? 0,
    );
  }
}
