import 'package:ciemsi_app/features/agenda/domain/repositories/agenda_repository.dart';

class EliminarAgendaUseCase {
  final AgendaRepository repository;
  EliminarAgendaUseCase(this.repository);

  Future<void> execute(int id) => repository.eliminarAgenda(id);
}
