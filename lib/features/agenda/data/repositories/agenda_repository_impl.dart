import 'package:ciemsi_app/features/agenda/data/datasources/agenda_remote_datasource.dart';
import 'package:ciemsi_app/features/agenda/domain/entities/agenda.dart';
import 'package:ciemsi_app/features/agenda/domain/repositories/agenda_repository.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class AgendaRepositoryImpl implements AgendaRepository {
  final AgendaRemoteDatasource remoteDatasource;

  AgendaRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Agenda>> listarAgendas({int? ciudadId}) =>
      remoteDatasource.listarAgendas(ciudadId: ciudadId);

  @override
  Future<void> crearAgenda(Map<String, dynamic> datos) =>
      remoteDatasource.crearAgenda(datos);

  @override
  Future<void> cambiarEstado(int id, bool estado) =>
      remoteDatasource.cambiarEstado(id, estado);

  @override
  Future<void> eliminarAgenda(int id) => remoteDatasource.eliminarAgenda(id);

  @override
  Future<List<Ciudad>> listarCiudades() => remoteDatasource.listarCiudades();
}
