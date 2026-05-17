import '../../domain/entities/alertas_suministro.dart';
import '../../domain/entities/inventario_result.dart';
import '../../domain/entities/suministro.dart';
import '../../domain/repositories/suministro_repository.dart';
import '../datasources/suministro_remote_datasource.dart';

class SuministroRepositoryImpl implements SuministroRepository {
  final SuministroRemoteDatasource remoteDatasource;

  SuministroRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Suministro>> listarSuministros({String? tipo}) =>
      remoteDatasource.listarSuministros(tipo: tipo);

  @override
  Future<void> crearSuministro({
    required String nombreSuministro,
    required String unidadMedida,
    String? marca,
    required String tipo,
    required int umbral,
  }) async {
    await remoteDatasource.crearSuministro(
      nombreSuministro: nombreSuministro,
      unidadMedida: unidadMedida,
      marca: marca,
      tipo: tipo,
      umbral: umbral,
    );
  }

  @override
  Future<InventarioResult> obtenerInventario(int ciudadId) async {
    final resultado = await remoteDatasource.obtenerInventario(ciudadId);
    return InventarioResult(
      inventario: resultado['inventario'],
      stockBajo: resultado['stockBajo'],
      totalItems: resultado['totalItems'] as int?,
    );
  }

  @override
  Future<AlertasSuministro> obtenerAlertas(int ciudadId) async {
    final resultado = await remoteDatasource.obtenerAlertas(ciudadId);
    return AlertasSuministro(
      stockBajo: resultado['stockBajo'] ?? [],
      proximosAVencer: resultado['proximosAVencer'] ?? [],
    );
  }

  @override
  Future<void> registrarCompra({
    required int ciudadId,
    required List<Map<String, dynamic>> items,
    String? fecha,
  }) async {
    await remoteDatasource.registrarCompra(
      ciudadId: ciudadId,
      items: items,
      fecha: fecha,
    );
  }
}
