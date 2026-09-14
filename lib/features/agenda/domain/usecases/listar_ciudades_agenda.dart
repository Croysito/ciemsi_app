import 'package:ciemsi_app/features/agenda/domain/repositories/agenda_repository.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class ListarCiudadesAgendaUseCase {
  final AgendaRepository repository;
  ListarCiudadesAgendaUseCase(this.repository);

  Future<List<Ciudad>> execute() => repository.listarCiudades();
}
