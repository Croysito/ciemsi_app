import 'package:ciemsi_app/features/citas/domain/entities/disponibilidad_dia.dart';
import 'package:ciemsi_app/features/citas/domain/repositories/cita_repository.dart';

class ObtenerDisponibilidadMesUseCase {
  final CitaRepository repository;
  ObtenerDisponibilidadMesUseCase(this.repository);

  Future<List<DisponibilidadDia>> execute({
    required int ciudadId,
    required int anio,
    required int mes,
  }) => repository.obtenerDisponibilidadMes(ciudadId: ciudadId, anio: anio, mes: mes);
}
