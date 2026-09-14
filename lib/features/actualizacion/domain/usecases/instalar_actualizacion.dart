import 'package:ciemsi_app/features/actualizacion/domain/repositories/actualizacion_repository.dart';

class InstalarActualizacionUseCase {
  final ActualizacionRepository repository;

  InstalarActualizacionUseCase(this.repository);

  Future<bool> solicitarPermiso() => repository.solicitarPermisoInstalacion();

  Future<void> call(String rutaArchivo) =>
      repository.instalarApk(rutaArchivo);
}
