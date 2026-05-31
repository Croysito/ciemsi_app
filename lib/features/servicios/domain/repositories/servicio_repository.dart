import '../entities/servicio.dart';

abstract class ServicioRepository {
  Future<List<Servicio>> listar();
  Future<void> crear(Map<String, dynamic> datos);
  Future<void> modificar(int id, Map<String, dynamic> datos);
}
