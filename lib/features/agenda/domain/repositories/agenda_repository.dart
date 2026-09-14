import 'package:ciemsi_app/features/agenda/domain/entities/agenda.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

abstract class AgendaRepository {
  Future<List<Agenda>> listarAgendas({int? ciudadId});

  Future<void> crearAgenda(Map<String, dynamic> datos);

  Future<void> cambiarEstado(int id, bool estado);

  Future<void> eliminarAgenda(int id);

  Future<List<Ciudad>> listarCiudades();
}
