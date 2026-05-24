import '../entities/traslado.dart';
import '../entities/traslado_datos_creacion.dart';
import '../entities/traslado_stock.dart';

abstract class TrasladoRepository {
  Future<List<Traslado>> listar(int ciudadId);
  Future<TrasladoDatosCreacion> obtenerDatosCreacion(int ciudadOrigenId);
  Future<TrasladoStock> consultarStock({
    required String tipo,
    required int itemId,
    required int ciudadOrigenId,
  });
  Future<void> crear({
    required String tipo,
    int? suministroId,
    int? productoId,
    required int ciudadOrigenId,
    required int ciudadDestinoId,
    required double cantidad,
  });
  Future<void> confirmar(int id);
  Future<void> devolver(int id);
}
