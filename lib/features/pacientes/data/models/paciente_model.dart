import '../../domain/entities/paciente.dart';
import 'ciudad_model.dart';

class PacienteModel extends Paciente {
  const PacienteModel({
    required super.id,
    required super.ci,
    required super.nombre,
    super.edad,
    super.telefono,
    super.fechaNacimiento,
    required super.ciudad,
  });

  factory PacienteModel.fromJson(Map<String, dynamic> json) {
    return PacienteModel(
      id: json['id'],
      ci: json['ci'],
      nombre: json['nombre'],
      edad: json['edad'],
      telefono: json['telefono']?.toString(),
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'])
          : null,
      ciudad: CiudadModel.fromJson(json['ciudad']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ci': ci,
    'nombre': nombre,
    'edad': edad,
    'telefono': telefono,
    'fechaNacimiento': fechaNacimiento?.toIso8601String(),
    'ciudad': (ciudad as CiudadModel).toJson(),
  };
}
