import '../repositories/tratamiento_repository.dart';

class AsignarTratamientoUseCase {
  final TratamientoRepository repository;

  AsignarTratamientoUseCase(this.repository);

  Future<void> execute({
    required int tratamientoId,
    required int citaId,
    double? precio,
    List<Map<String, dynamic>>? medicamentos,
  }) => repository.asignarTratamiento(
    tratamientoId: tratamientoId,
    citaId: citaId,
    precio: precio,
    medicamentos: medicamentos,
  );
}
