import '../entities/asistente.dart';
import '../entities/asistente_registro_result.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

abstract class AsistenteRepository {
  Future<List<Asistente>> listarAsistentes();

  Future<List<Ciudad>> listarCiudades();

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
