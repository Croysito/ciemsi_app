import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/historial_model.dart';
import '../models/nota_model.dart';
import '../models/link_model.dart';

class HistorialRemoteDatasource {
  final ApiClient apiClient;
  HistorialRemoteDatasource(this.apiClient);

  Future<HistorialModel> obtenerHistorial(int pacienteId) async {
    try {
      final response = await apiClient.dio.get('/historial/$pacienteId');
      return HistorialModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al obtener historial'));
    }
  }

  Future<NotaModel> agregarNota(int pacienteId, String detalle) async {
    try {
      final response = await apiClient.dio.post(
        '/historial/$pacienteId/notas',
        data: {'detalle': detalle},
      );
      return NotaModel.fromJson(response.data['nota']);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al agregar nota'));
    }
  }

  Future<LinkModel> agregarLink({
    required int notaId,
    required String nombre,
    required String link,
    required String tipo,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/historial/notas/$notaId/links',
        data: {'nombre': nombre, 'link': link, 'tipo': tipo},
      );
      return LinkModel.fromJson(response.data['link']);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al agregar link'));
    }
  }

  Future<LinkModel> subirArchivoDrive({
    required int notaId,
    required String tipo,
    required String tokens,
    required List<int> bytes,
    required String nombre,
    required String mimeType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'tipo': tipo,
        'tokens': tokens,
        'archivo': MultipartFile.fromBytes(
          bytes,
          filename: nombre,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final response = await apiClient.dio.post(
        '/drive/upload/$notaId',
        data: formData,
      );
      return LinkModel.fromJson(response.data['link']);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al subir archivo'));
    }
  }

  Future<List<LinkModel>> obtenerLinksPorTipo(int notaId, String tipo) async {
    try {
      final response = await apiClient.dio.get(
        '/historial/notas/$notaId/links',
        queryParameters: {'tipo': tipo},
      );
      return (response.data as List).map((l) => LinkModel.fromJson(l)).toList();
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al obtener links'));
    }
  }

  Future<HistorialModel> obtenerMiHistorial() async {
    try {
      final response = await apiClient.dio.get('/historial/mi-historial');
      return HistorialModel.fromJson(response.data['historial']);
    } on DioException catch (e) {
      throw Exception(ApiClient.errorMessage(e, 'Error al obtener historial'));
    }
  }
}
