import '../repositories/cita_repository.dart';

class ObtenerHorasDisponiblesUseCase {
  final CitaRepository repository;

  ObtenerHorasDisponiblesUseCase(this.repository);

  Future<List<String>> execute({
    required int ciudadId,
    required String fecha,
  }) => repository.obtenerHorasDisponibles(ciudadId: ciudadId, fecha: fecha);
}
