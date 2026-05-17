import '../entities/alertas_suministro.dart';
import '../repositories/suministro_repository.dart';

class ObtenerAlertasSuministroUseCase {
  final SuministroRepository repository;

  ObtenerAlertasSuministroUseCase(this.repository);

  Future<AlertasSuministro> execute(int ciudadId) =>
      repository.obtenerAlertas(ciudadId);
}
