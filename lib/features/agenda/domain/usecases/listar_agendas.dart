import 'package:ciemsi_app/features/agenda/domain/entities/agenda.dart';
import 'package:ciemsi_app/features/agenda/domain/repositories/agenda_repository.dart';

class ListarAgendasUseCase {
  final AgendaRepository repository;
  ListarAgendasUseCase(this.repository);

  Future<List<Agenda>> execute({int? ciudadId}) =>
      repository.listarAgendas(ciudadId: ciudadId);
}
