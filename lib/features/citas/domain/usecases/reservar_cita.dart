import '../repositories/cita_repository.dart';

class ReservarCitaUseCase {
  final CitaRepository repository;

  ReservarCitaUseCase(this.repository);

  Future<void> execute({
    required String fecha,
    required String hora,
    required int servicioId,
    int? pacienteId,
    int? ciudadId,
    int? agendaId,
    String? notas,
  }) => repository.reservarCita(
    fecha: fecha,
    hora: hora,
    servicioId: servicioId,
    pacienteId: pacienteId,
    ciudadId: ciudadId,
    agendaId: agendaId,
    notas: notas,
  );
}
