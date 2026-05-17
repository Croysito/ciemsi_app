import '../repositories/tratamiento_repository.dart';

class GenerarRecetaTratamientoUseCase {
  final TratamientoRepository repository;

  GenerarRecetaTratamientoUseCase(this.repository);

  Future<Map<String, dynamic>> execute({
    required int citaId,
    required String detalle,
  }) => repository.generarReceta(citaId: citaId, detalle: detalle);
}
