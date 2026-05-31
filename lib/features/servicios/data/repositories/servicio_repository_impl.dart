import '../../domain/entities/servicio.dart';
import '../../domain/repositories/servicio_repository.dart';
import '../datasources/servicio_remote_datasource.dart';

class ServicioRepositoryImpl implements ServicioRepository {
  final ServicioRemoteDatasource _datasource;
  ServicioRepositoryImpl(this._datasource);

  @override
  Future<List<Servicio>> listar() => _datasource.listar();

  @override
  Future<void> crear(Map<String, dynamic> datos) => _datasource.crear(datos);

  @override
  Future<void> modificar(int id, Map<String, dynamic> datos) =>
      _datasource.modificar(id, datos);
}
