import 'package:ciemsi_app/features/actualizacion/domain/entities/version_disponible.dart';

/// Mapea la respuesta de `GET /repos/{owner}/{repo}/releases/latest` de la
/// API de GitHub a [VersionDisponible].
class VersionDisponibleModel extends VersionDisponible {
  const VersionDisponibleModel({
    required super.version,
    required super.urlDescarga,
    super.notas,
  });

  /// Devuelve null si el release no trae un asset .apk (ej. un release
  /// mal publicado, o de otro tipo).
  static VersionDisponibleModel? fromJson(Map<String, dynamic> json) {
    final tag = (json['tag_name'] as String?)?.trim();
    if (tag == null || tag.isEmpty) return null;

    final assets = (json['assets'] as List?) ?? const [];
    Map<String, dynamic>? apkAsset;
    for (final asset in assets) {
      final nombre = (asset['name'] as String?)?.toLowerCase() ?? '';
      if (nombre.endsWith('.apk')) {
        apkAsset = asset as Map<String, dynamic>;
        break;
      }
    }
    if (apkAsset == null) return null;

    final urlDescarga = apkAsset['browser_download_url'] as String?;
    if (urlDescarga == null || urlDescarga.isEmpty) return null;

    return VersionDisponibleModel(
      version: tag.replaceFirst(RegExp(r'^v', caseSensitive: false), ''),
      urlDescarga: urlDescarga,
      notas: (json['body'] as String?)?.trim(),
    );
  }
}
