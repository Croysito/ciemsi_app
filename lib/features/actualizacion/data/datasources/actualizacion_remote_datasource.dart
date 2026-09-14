import 'package:ciemsi_app/features/actualizacion/data/models/version_disponible_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Consulta la API pública de GitHub (no la de CIEMSI) para saber cuál es
/// el último release publicado del repo de distribución del APK.
///
/// Usa una instancia de Dio propia (no el ApiClient de la app) porque
/// apunta a un host distinto y no necesita el token de sesión.
class ActualizacionRemoteDatasource {
  static const String _repo = 'Croysito/ciemsi-descarga';

  final Dio _dio;

  ActualizacionRemoteDatasource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.github.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: const {'Accept': 'application/vnd.github+json'},
            ),
          );

  /// Devuelve null si no se pudo consultar o si el release más nuevo no
  /// trae un asset .apk válido. Nunca lanza — un fallo de red al chequear
  /// actualizaciones no debe interrumpir el uso normal de la app.
  Future<VersionDisponibleModel?> obtenerUltimoRelease() async {
    try {
      final respuesta = await _dio.get('/repos/$_repo/releases/latest');
      final data = respuesta.data;
      if (data is! Map<String, dynamic>) return null;
      return VersionDisponibleModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) debugPrint('[Actualizacion] error al consultar: $e');
      return null;
    }
  }
}
