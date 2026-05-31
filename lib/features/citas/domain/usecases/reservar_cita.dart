import '../repositories/cita_repository.dart';

class ReservarCitaUseCase {
  final CitaRepository repository;

  ReservarCitaUseCase(this.repository);

  Future<int> execute({
    required String fecha,
    required String hora,
    required int servicioId,
    int? pacienteId,
    int? ciudadId,
    int? agendaId,
    String? notas,
    double? adelantoMonto,
    String? adelantoMetodo,
  }) => repository.reservarCita(
    fecha: fecha,
    hora: hora,
    servicioId: servicioId,
    pacienteId: pacienteId,
    ciudadId: ciudadId,
    agendaId: agendaId,
    notas: notas,
    adelantoMonto: adelantoMonto,
    adelantoMetodo: adelantoMetodo,
  );
}
