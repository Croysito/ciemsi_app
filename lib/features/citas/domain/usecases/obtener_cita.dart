import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/citas/domain/repositories/cita_repository.dart';

class ObtenerCitaUseCase {
  final CitaRepository repository;
  ObtenerCitaUseCase(this.repository);

  Future<CitaMedica> execute(int id) => repository.obtenerCita(id);
}
