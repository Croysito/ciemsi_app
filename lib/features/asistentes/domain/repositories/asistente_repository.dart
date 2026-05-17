import '../entities/asistente.dart';
import '../entities/asistente_registro_result.dart';

abstract class AsistenteRepository {
  Future<List<Asistente>> listarAsistentes();

  Future<AsistenteRegistroResult> crearAsistente({
    required String nombre,
    required String apellido,
    required String email,
    required String ci,
    required int ciudadId,
  });

  Future<void> modificarAsistente({
    required int id,
    required String nombre,
    required String apellido,
    required String email,
    required int ciudadId,
  });

  Future<void> cambiarEstado(int id, bool estado);

  Future<void> cambiarPassword({
    required String passwordActual,
    required String passwordNuevo,
  });
}
