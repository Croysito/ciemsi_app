import '../entities/tratamiento.dart';
import '../entities/tratamiento_asignado.dart';

abstract class TratamientoRepository {
  Future<List<Tratamiento>> listarTratamientos();

  Future<void> crearTratamiento({
    required String nombreTratamiento,
    String? detalle,
    double? precioBase,
    List<Map<String, dynamic>> medicamentosBase,
  });

  Future<void> asignarTratamiento({
    required int tratamientoId,
    required int citaId,
    double? precio,
    List<Map<String, dynamic>>? medicamentos,
  });

  Future<List<TratamientoAsignado>> listarAsignados();

  Future<List<TratamientoAsignado>> listarAsignadosByCita(int citaId);

  Future<void> agregarSuministro({
    required int tratamientoAsignadoId,
    required int suministroId,
    required int cantidad,
  });

  Future<void> completarTratamiento(int id);

  Future<Map<String, dynamic>> generarReceta({
    required int citaId,
    required String detalle,
  });
}
