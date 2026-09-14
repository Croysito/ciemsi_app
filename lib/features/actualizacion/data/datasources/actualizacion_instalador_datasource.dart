import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Encapsula el acceso a plataforma (descarga a disco, permisos de
/// instalación y disparo del instalador nativo de Android) que necesita
/// el flujo de autoactualización.
class ActualizacionInstaladorDatasource {
  final Dio _dio;

  ActualizacionInstaladorDatasource({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> descargarApk(
    String url, {
    required void Function(double progreso) onProgreso,
  }) async {
    final directorio = await getTemporaryDirectory();
    final rutaArchivo = '${directorio.path}/ciemsi_actualizacion.apk';

    await _dio.download(
      url,
      rutaArchivo,
      onReceiveProgress: (recibidos, total) {
        if (total <= 0) return;
        onProgreso(recibidos / total);
      },
    );

    return rutaArchivo;
  }

  Future<bool> solicitarPermisoInstalacion() async {
    final estado = await Permission.requestInstallPackages.status;
    if (estado.isGranted) return true;

    final nuevoEstado = await Permission.requestInstallPackages.request();
    return nuevoEstado.isGranted;
  }

  Future<void> instalarApk(String rutaArchivo) async {
    if (!await File(rutaArchivo).exists()) {
      throw Exception('El instalador descargado ya no existe');
    }
    final resultado = await OpenFilex.open(rutaArchivo);
    if (resultado.type != ResultType.done) {
      throw Exception(resultado.message);
    }
  }
}
