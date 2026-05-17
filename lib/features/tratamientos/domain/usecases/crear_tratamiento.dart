import '../repositories/tratamiento_repository.dart';

class CrearTratamientoUseCase {
  final TratamientoRepository repository;

  CrearTratamientoUseCase(this.repository);

  Future<void> execute({
    required String nombreTratamiento,
    String? detalle,
    double? precioBase,
    List<Map<String, dynamic>> medicamentosBase = const [],
  }) => repository.crearTratamiento(
    nombreTratamiento: nombreTratamiento,
    detalle: detalle,
    precioBase: precioBase,
    medicamentosBase: medicamentosBase,
  );
}
