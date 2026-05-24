import '../entities/traslado_datos_creacion.dart';
import '../repositories/traslado_repository.dart';

class ObtenerDatosCreacionTrasladoUseCase {
  final TrasladoRepository repository;

  ObtenerDatosCreacionTrasladoUseCase(this.repository);

  Future<TrasladoDatosCreacion> execute(int ciudadOrigenId) =>
      repository.obtenerDatosCreacion(ciudadOrigenId);
}
