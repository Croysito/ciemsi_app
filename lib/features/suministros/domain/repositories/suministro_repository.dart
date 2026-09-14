import '../entities/alertas_suministro.dart';
import '../entities/ciudad_inventario.dart';
import '../entities/inventario_comparado.dart';
import '../entities/inventario_result.dart';
import '../entities/suministro.dart';

abstract class SuministroRepository {
  Future<List<Suministro>> listarSuministros({String? tipo});

  Future<void> crearSuministro({
    required String nombreSuministro,
    required String unidadMedida,
    String? marca,
    required String tipo,
    required int umbral,
  });

  Future<InventarioResult> obtenerInventario(int ciudadId);

  /// Ciudades visibles para el usuario, ya con abreviatura y color de
  /// configuración (P4 · CiudadInventarioEstilos).
  Future<List<CiudadInventario>> listarCiudadesInventario();

  /// P4 · Inventario comparado: une el inventario de cada ciudad visible
  /// por id de suministro. Fallback cliente — una llamada por ciudad,
  /// mientras el backend no tenga un endpoint multi-ciudad; el spec pide
  /// explícitamente que esta unión viva en el repositorio, no en el widget.
  Future<InventarioComparado> obtenerInventarioComparado(List<CiudadInventario> ciudades);

  Future<AlertasSuministro> obtenerAlertas(int ciudadId);

  Future<void> registrarCompra({
    required int ciudadId,
    required List<Map<String, dynamic>> items,
    String? fecha,
  });
}
