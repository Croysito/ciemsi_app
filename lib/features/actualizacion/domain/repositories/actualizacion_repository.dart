import 'package:ciemsi_app/features/actualizacion/domain/entities/version_disponible.dart';

abstract class ActualizacionRepository {
  /// Consulta el último release publicado. Devuelve null si no se pudo
  /// consultar (sin conexión, GitHub caído, etc.) — un fallo acá nunca
  /// debe impedir el uso normal de la app.
  Future<VersionDisponible?> obtenerUltimaVersion();

  /// Descarga el APK del [url] indicado a un archivo temporal y reporta
  /// el progreso (0.0 a 1.0). Devuelve la ruta local del archivo descargado.
  Future<String> descargarApk(
    String url, {
    required void Function(double progreso) onProgreso,
  });

  /// Pide (si hace falta) el permiso especial de Android para instalar
  /// APKs de origen desconocido. Devuelve true si quedó concedido.
  Future<bool> solicitarPermisoInstalacion();

  /// Abre el instalador nativo de Android para el APK en [rutaArchivo].
  Future<void> instalarApk(String rutaArchivo);

  /// Versión actualmente instalada (ej. "1.0.2"), leída de package_info.
  Future<String> obtenerVersionActual();
}
