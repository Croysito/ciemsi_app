import 'package:ciemsi_app/features/agenda/domain/repositories/agenda_repository.dart';

class CrearAgendaUseCase {
  final AgendaRepository repository;
  CrearAgendaUseCase(this.repository);

  Future<void> execute(Map<String, dynamic> datos) =>
      repository.crearAgenda(datos);
}
