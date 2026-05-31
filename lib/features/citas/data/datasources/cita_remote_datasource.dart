import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:ciemsi_app/features/citas/data/models/cita_model.dart';
import 'package:ciemsi_app/features/agenda/data/models/agenda_model.dart';
import 'package:ciemsi_app/features/servicios/data/models/servicio_model.dart';

class CitaRemoteDatasource {
  final ApiClient apiClient;
  CitaRemoteDatasource(this.apiClient);

  Future<List<CitaModel>> listarCitas() async {
    try {
      final response = await apiClient.dio.get('/citas');
      return (response.data as List).map((c) => CitaModel.fromJson(c)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al listar citas');
    }
  }

  Future<Map<String, dynamic>> reservarCita({
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
    try {
      final response = await apiClient.dio.post(
        '/citas',
        data: {
          'fecha': fecha,
          'hora': hora,
          'servicioId': servicioId,
          if (pacienteId != null) 'pacienteId': pacienteId,
          if (ciudadId != null) 'ciudadId': ciudadId,
          if (agendaId != null) 'agendaId': agendaId,
          if (notas != null) 'notas': notas,
          if (adelantoMonto != null) 'adelantoMonto': adelantoMonto,
          if (adelantoMetodo != null) 'adelantoMetodo': adelantoMetodo,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al reservar cita');
    }
  }

  Future<void> cambiarEstado(int id, String estado, {String? notas}) async {
    try {
      await apiClient.dio.patch(
        '/citas/$id/estado',
        data: {'estado': estado, if (notas != null) 'notas': notas},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al cambiar estado');
    }
  }

  Future<void> modificarCita({
    required int id,
    required String fecha,
    required String hora,
    required int servicioId,
    String? notas,
  }) async {
    try {
      await apiClient.dio.put(
        '/citas/$id',
        data: {
          'fecha': fecha,
          'hora': hora,
          'servicioId': servicioId,
          if (notas != null) 'notas': notas,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al modificar cita');
    }
  }

  Future<List<ServicioModel>> listarServicios() async {
    try {
      final response = await apiClient.dio.get('/servicios');
      return (response.data as List)
          .map((s) => ServicioModel.fromJson(s))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al listar servicios',
      );
    }
  }

  Future<Map<String, dynamic>> obtenerDisponibilidad({
    required int ciudadId,
    required String fecha,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/agenda/disponibilidad',
        queryParameters: {'ciudadId': ciudadId, 'fecha': fecha},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al obtener disponibilidad',
      );
    }
  }

  Future<List<AgendaModel>> listarAgenda(int ciudadId) async {
    try {
      final response = await apiClient.dio.get(
        '/agenda',
        queryParameters: {'ciudadId': ciudadId},
      );
      return (response.data as List)
          .map((a) => AgendaModel.fromJson(a))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al listar agenda');
    }
  }

  Future<void> crearAgenda({
    String? fecha,
    List<String>? diasSemana,
    required String horaInicio,
    required String horaFin,
    required int intervalo,
    required int ciudadId,
  }) async {
    try {
      await apiClient.dio.post(
        '/agenda',
        data: {
          if (fecha != null) 'fecha': fecha,
          if (diasSemana != null) 'diasSemana': diasSemana,
          'horaInicio': horaInicio,
          'horaFin': horaFin,
          'intervalo': intervalo,
          'ciudadId': ciudadId,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al crear agenda');
    }
  }

  Future<Map<String, dynamic>> obtenerQrPago() async {
    try {
      final response = await apiClient.dio.get('/citas/config/qr-pago');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al obtener QR');
    }
  }

  Future<void> actualizarQrPago(String qrLink) async {
    try {
      await apiClient.dio.put('/citas/config/qr-pago', data: {'qrLink': qrLink});
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al actualizar QR');
    }
  }

  Future<String> subirComprobante({
    required int citaId,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'comprobante': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      });
      final response = await apiClient.dio.post(
        '/citas/$citaId/comprobante',
        data: formData,
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );
      return (response.data as Map<String, dynamic>)['comprobantePath'] as String;
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al subir comprobante');
    }
  }

  Future<void> confirmarPago(int citaId) async {
    try {
      await apiClient.dio.post('/citas/$citaId/confirmar-pago');
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al confirmar pago');
    }
  }

  Future<Uint8List> obtenerComprobante(int citaId) async {
    try {
      final response = await apiClient.dio.get(
        '/citas/$citaId/comprobante',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data as List<int>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al obtener comprobante');
    }
  }

  Future<void> eliminarAgenda(int id) async {
    try {
      await apiClient.dio.delete('/agenda/$id');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['mensaje'] ?? 'Error al eliminar agenda',
      );
    }
  }
}
