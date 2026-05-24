import '../../domain/entities/traslado.dart';
import '../../domain/entities/traslado_datos_creacion.dart';
import '../../domain/entities/traslado_stock.dart';
import '../../domain/repositories/traslado_repository.dart';
import '../datasources/traslado_remote_datasource.dart';

class TrasladoRepositoryImpl implements TrasladoRepository {
  final TrasladoRemoteDatasource datasource;
  TrasladoRepositoryImpl(this.datasource);

  @override
  Future<List<Traslado>> listar(int ciudadId) => datasource.listar(ciudadId);

  @override
  Future<TrasladoDatosCreacion> obtenerDatosCreacion(int ciudadOrigenId) =>
      datasource.obtenerDatosCreacion(ciudadOrigenId);

  @override
  Future<TrasladoStock> consultarStock({
    required String tipo,
    required int itemId,
    required int ciudadOrigenId,
  }) => datasource.consultarStock(
    tipo: tipo,
    itemId: itemId,
    ciudadOrigenId: ciudadOrigenId,
  );

  @override
  Future<void> crear({
    required String tipo,
    int? suministroId,
    int? productoId,
    required int ciudadOrigenId,
    required int ciudadDestinoId,
    required double cantidad,
  }) => datasource.crear(
    tipo: tipo,
    suministroId: suministroId,
    productoId: productoId,
    ciudadOrigenId: ciudadOrigenId,
    ciudadDestinoId: ciudadDestinoId,
    cantidad: cantidad,
  );

  @override
  Future<void> confirmar(int id) => datasource.confirmar(id);

  @override
  Future<void> devolver(int id) => datasource.devolver(id);
}
