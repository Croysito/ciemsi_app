import 'dart:typed_data';
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
  Future<int> reservarCita({
    required String fecha,
    required String hora,
    required int servicioId,
    int? pacienteId,
    int? ciudadId,
    int? agendaId,
    String? notas,
    double? adelantoMonto,
    String? adelantoMetodo,
  }) async {
    final result = await remoteDatasource.reservarCita(
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
    return result['citaId'] as int;
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

  @override
  Future<Map<String, dynamic>> obtenerQrPago() =>
      remoteDatasource.obtenerQrPago();

  @override
  Future<void> actualizarQrPago(String qrLink) =>
      remoteDatasource.actualizarQrPago(qrLink);

  @override
  Future<String> subirComprobante({
    required int citaId,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) => remoteDatasource.subirComprobante(
    citaId: citaId,
    bytes: bytes,
    fileName: fileName,
    mimeType: mimeType,
  );

  @override
  Future<void> confirmarPago(int citaId) =>
      remoteDatasource.confirmarPago(citaId);
}
