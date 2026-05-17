import '../repositories/cita_repository.dart';

class ModificarCitaUseCase {
  final CitaRepository repository;

  ModificarCitaUseCase(this.repository);

  Future<void> execute({
    required int id,
    required String fecha,
    required String hora,
    required int servicioId,
    String? notas,
  }) => repository.modificarCita(
    id: id,
    fecha: fecha,
    hora: hora,
    servicioId: servicioId,
    notas: notas,
  );
}
