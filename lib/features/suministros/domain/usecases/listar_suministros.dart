import '../entities/suministro.dart';
import '../repositories/suministro_repository.dart';

class ListarSuministrosUseCase {
  final SuministroRepository repository;

  ListarSuministrosUseCase(this.repository);

  Future<List<Suministro>> execute({String? tipo}) =>
      repository.listarSuministros(tipo: tipo);
}
