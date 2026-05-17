import '../../domain/entities/tratamiento.dart';
import '../../domain/entities/tratamiento_asignado.dart';
import '../../domain/repositories/tratamiento_repository.dart';
import '../datasources/tratamiento_remote_datasource.dart';

class TratamientoRepositoryImpl implements TratamientoRepository {
  final TratamientoRemoteDatasource remoteDatasource;

  TratamientoRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Tratamiento>> listarTratamientos() =>
      remoteDatasource.listarTratamientos();

  @override
  Future<void> crearTratamiento({
    required String nombreTratamiento,
    String? detalle,
    double? precioBase,
    List<Map<String, dynamic>> medicamentosBase = const [],
  }) async {
    await remoteDatasource.crearTratamiento(
      nombreTratamiento: nombreTratamiento,
      detalle: detalle,
      precioBase: precioBase,
      medicamentosBase: medicamentosBase,
    );
  }

  @override
  Future<void> asignarTratamiento({
    required int tratamientoId,
    required int citaId,
    double? precio,
    List<Map<String, dynamic>>? medicamentos,
  }) async {
    await remoteDatasource.asignarTratamiento(
      tratamientoId: tratamientoId,
      citaId: citaId,
      precio: precio,
      medicamentos: medicamentos,
    );
  }

  @override
  Future<List<TratamientoAsignado>> listarAsignados() =>
      remoteDatasource.listarAsignados();

  @override
  Future<List<TratamientoAsignado>> listarAsignadosByCita(int citaId) =>
      remoteDatasource.listarAsignadosByCita(citaId);

  @override
  Future<void> agregarSuministro({
    required int tratamientoAsignadoId,
    required int suministroId,
    required int cantidad,
  }) => remoteDatasource.agregarSuministro(
    tratamientoAsignadoId: tratamientoAsignadoId,
    suministroId: suministroId,
    cantidad: cantidad,
  );

  @override
  Future<void> completarTratamiento(int id) =>
      remoteDatasource.completarTratamiento(id);

  @override
  Future<Map<String, dynamic>> generarReceta({
    required int citaId,
    required String detalle,
  }) => remoteDatasource.generarReceta(citaId: citaId, detalle: detalle);
}
