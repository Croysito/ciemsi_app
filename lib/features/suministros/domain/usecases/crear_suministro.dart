import '../repositories/suministro_repository.dart';

class CrearSuministroUseCase {
  final SuministroRepository repository;

  CrearSuministroUseCase(this.repository);

  Future<void> execute({
    required String nombreSuministro,
    required String unidadMedida,
    String? marca,
    required String tipo,
    required int umbral,
  }) => repository.crearSuministro(
    nombreSuministro: nombreSuministro,
    unidadMedida: unidadMedida,
    marca: marca,
    tipo: tipo,
    umbral: umbral,
  );
}
