import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import '../repositories/asistente_repository.dart';

class ListarCiudadesAsistenteUseCase {
  final AsistenteRepository repository;
  ListarCiudadesAsistenteUseCase(this.repository);

  Future<List<Ciudad>> execute() => repository.listarCiudades();
}
