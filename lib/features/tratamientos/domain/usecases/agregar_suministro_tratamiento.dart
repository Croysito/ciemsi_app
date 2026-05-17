import '../repositories/tratamiento_repository.dart';

class AgregarSuministroTratamientoUseCase {
  final TratamientoRepository repository;

  AgregarSuministroTratamientoUseCase(this.repository);

  Future<void> execute({
    required int tratamientoAsignadoId,
    required int suministroId,
    required int cantidad,
  }) => repository.agregarSuministro(
    tratamientoAsignadoId: tratamientoAsignadoId,
    suministroId: suministroId,
    cantidad: cantidad,
  );
}
