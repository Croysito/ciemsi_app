import 'package:equatable/equatable.dart';

/// Representa una versión de la app publicada como GitHub Release
/// en `github.com/Croysito/ciemsi-descarga`.
class VersionDisponible extends Equatable {
  final String version; // ej. "1.0.3" (sin la "v" del tag)
  final String urlDescarga; // browser_download_url del asset .apk
  final String? notas; // cuerpo del release, para mostrar al usuario

  const VersionDisponible({
    required this.version,
    required this.urlDescarga,
    this.notas,
  });

  @override
  List<Object?> get props => [version, urlDescarga, notas];
}
