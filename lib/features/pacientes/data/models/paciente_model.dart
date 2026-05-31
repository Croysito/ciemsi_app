import 'package:ciemsi_app/features/pacientes/domain/entities/paciente.dart';
import 'package:ciemsi_app/features/auth/data/models/usuario_model.dart';

class PacienteModel extends Paciente {
  const PacienteModel({
    required super.id,
    required super.ci,
    super.telefono,
    super.fechaNacimiento,
    super.genero,
    required super.usuario,
  });

  factory PacienteModel.fromJson(Map<String, dynamic> json) {
    return PacienteModel(
      id: json['id'],
      ci: json['ci'],
      telefono: json['telefono']?.toString(),
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'])
          : null,
      genero: json['genero']?.toString(),
      usuario: UsuarioModel.fromJson(json['usuario']),
    );
  }
}
