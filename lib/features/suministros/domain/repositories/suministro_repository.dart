import '../entities/alertas_suministro.dart';
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

  Future<AlertasSuministro> obtenerAlertas(int ciudadId);

  Future<void> registrarCompra({
    required int ciudadId,
    required List<Map<String, dynamic>> items,
    String? fecha,
  });
}
