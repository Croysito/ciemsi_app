import 'package:ciemsi_app/features/actualizacion/domain/entities/version_disponible.dart';
import 'package:ciemsi_app/features/actualizacion/domain/repositories/actualizacion_repository.dart';
import 'package:ciemsi_app/features/actualizacion/domain/utils/comparador_version.dart';

/// Devuelve la [VersionDisponible] si hay una versión más nueva publicada
/// que la instalada, o null si ya está al día (o si no se pudo consultar).
class VerificarActualizacionUseCase {
  final ActualizacionRepository repository;

  VerificarActualizacionUseCase(this.repository);

  Future<VersionDisponible?> call() async {
    final remota = await repository.obtenerUltimaVersion();
    if (remota == null) return null;

    final actual = await repository.obtenerVersionActual();
    if (!esVersionMasNueva(remota: remota.version, local: actual)) {
      return null;
    }
    return remota;
  }
}
