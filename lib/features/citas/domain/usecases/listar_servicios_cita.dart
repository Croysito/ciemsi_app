import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

import '../repositories/cita_repository.dart';

class ListarServiciosCitaUseCase {
  final CitaRepository repository;

  ListarServiciosCitaUseCase(this.repository);

  Future<List<Servicio>> execute() => repository.listarServicios();
}
