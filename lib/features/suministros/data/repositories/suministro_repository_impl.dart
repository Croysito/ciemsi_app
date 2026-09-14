import '../../domain/entities/alertas_suministro.dart';
import '../../domain/entities/ciudad_inventario.dart';
import '../../domain/entities/inventario_comparado.dart';
import '../../domain/entities/inventario_item.dart';
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

  @override
  Future<List<CiudadInventario>> listarCiudadesInventario() async {
    final ciudades = await remoteDatasource.listarCiudades();
    return CiudadInventarioEstilos.resolver(ciudades);
  }

  @override
  Future<InventarioComparado> obtenerInventarioComparado(List<CiudadInventario> ciudades) async {
    final resultados = await Future.wait(ciudades.map((c) => remoteDatasource.obtenerInventario(c.id)));

    final saldosPorItem = <int, Map<int, double>>{};
    final metaPorItem = <int, InventarioItem>{};
    for (var i = 0; i < ciudades.length; i++) {
      final inventario = resultados[i]['inventario'] as List<InventarioItem>;
      for (final item in inventario) {
        saldosPorItem.putIfAbsent(item.id, () => {})[ciudades[i].id] = item.saldo;
        // El umbral y el nombre son del suministro, no de la fila de
        // ciudad — cualquier ciudad sirve de fuente, se quedan con la
        // primera que aparece.
        metaPorItem.putIfAbsent(item.id, () => item);
      }
    }

    final items = metaPorItem.entries.map((entry) {
      final id = entry.key;
      final meta = entry.value;
      final saldos = saldosPorItem[id]!.entries.map((e) => SaldoCiudad(ciudadId: e.key, saldo: e.value)).toList();
      return ItemComparado(
        id: id,
        nombreSuministro: meta.nombreSuministro,
        unidadMedida: meta.unidadMedida,
        tipo: meta.tipo,
        umbral: meta.umbral,
        saldos: saldos,
      );
    }).toList()
      ..sort((a, b) => a.nombreSuministro.compareTo(b.nombreSuministro));

    return InventarioComparado(ciudades: ciudades, items: items);
  }
}
