import '../repositories/pago_repository.dart';

class ObtenerMiPerfilPacienteUseCase {
  final PagoRepository repository;
  ObtenerMiPerfilPacienteUseCase(this.repository);

  Future<Map<String, dynamic>> execute() =>
      repository.obtenerMiPerfilPaciente();
}
