import 'package:ciemsi_app/features/actualizacion/data/datasources/actualizacion_instalador_datasource.dart';
import 'package:ciemsi_app/features/actualizacion/data/datasources/actualizacion_remote_datasource.dart';
import 'package:ciemsi_app/features/actualizacion/domain/entities/version_disponible.dart';
import 'package:ciemsi_app/features/actualizacion/domain/repositories/actualizacion_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ActualizacionRepositoryImpl implements ActualizacionRepository {
  final ActualizacionRemoteDatasource remoteDatasource;
  final ActualizacionInstaladorDatasource instaladorDatasource;

  ActualizacionRepositoryImpl({
    required this.remoteDatasource,
    required this.instaladorDatasource,
  });

  @override
  Future<VersionDisponible?> obtenerUltimaVersion() {
    return remoteDatasource.obtenerUltimoRelease();
  }

  @override
  Future<String> obtenerVersionActual() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  @override
  Future<String> descargarApk(
    String url, {
    required void Function(double progreso) onProgreso,
  }) {
    return instaladorDatasource.descargarApk(url, onProgreso: onProgreso);
  }

  @override
  Future<bool> solicitarPermisoInstalacion() {
    return instaladorDatasource.solicitarPermisoInstalacion();
  }

  @override
  Future<void> instalarApk(String rutaArchivo) {
    return instaladorDatasource.instalarApk(rutaArchivo);
  }
}
