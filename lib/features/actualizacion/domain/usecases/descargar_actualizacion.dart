import 'package:ciemsi_app/features/actualizacion/domain/repositories/actualizacion_repository.dart';

class DescargarActualizacionUseCase {
  final ActualizacionRepository repository;

  DescargarActualizacionUseCase(this.repository);

  Future<String> call(
    String url, {
    required void Function(double progreso) onProgreso,
  }) {
    return repository.descargarApk(url, onProgreso: onProgreso);
  }
}
