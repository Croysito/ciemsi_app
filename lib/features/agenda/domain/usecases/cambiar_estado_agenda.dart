import 'package:ciemsi_app/features/agenda/domain/repositories/agenda_repository.dart';

class CambiarEstadoAgendaUseCase {
  final AgendaRepository repository;
  CambiarEstadoAgendaUseCase(this.repository);

  Future<void> execute(int id, bool estado) =>
      repository.cambiarEstado(id, estado);
}
