import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/citas/domain/repositories/cita_repository.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

import '../datasources/cita_remote_datasource.dart';

class CitaRepositoryImpl implements CitaRepository {
  final CitaRemoteDatasource remoteDatasource;

  CitaRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<CitaMedica>> listarCitas() => remoteDatasource.listarCitas();

  @override
  Future<void> reservarCita({
    required String fecha,
    required String hora,
    required int servicioId,
    int? pacienteId,
    int? ciudadId,
    int? agendaId,
    String? notas,
  }) async {
    await remoteDatasource.reservarCita(
      fecha: fecha,
      hora: hora,
      servicioId: servicioId,
      pacienteId: pacienteId,
      ciudadId: ciudadId,
      agendaId: agendaId,
      notas: notas,
    );
  }

  @override
  Future<void> modificarCita({
    required int id,
    required String fecha,
    required String hora,
    required int servicioId,
    String? notas,
  }) => remoteDatasource.modificarCita(
    id: id,
    fecha: fecha,
    hora: hora,
    servicioId: servicioId,
    notas: notas,
  );

  @override
  Future<void> cambiarEstado(int id, String estado, {String? notas}) =>
      remoteDatasource.cambiarEstado(id, estado, notas: notas);

  @override
  Future<List<Servicio>> listarServicios() =>
      remoteDatasource.listarServicios();

  @override
  Future<List<String>> obtenerHorasDisponibles({
    required int ciudadId,
    required String fecha,
  }) async {
    final resultado = await remoteDatasource.obtenerDisponibilidad(
      ciudadId: ciudadId,
      fecha: fecha,
    );
    return List<String>.from(resultado['horasDisponibles'] ?? []);
  }
}
