import '../repositories/suministro_repository.dart';

class RegistrarCompraUseCase {
  final SuministroRepository repository;

  RegistrarCompraUseCase(this.repository);

  Future<void> execute({
    required int ciudadId,
    required List<Map<String, dynamic>> items,
    String? fecha,
  }) => repository.registrarCompra(
    ciudadId: ciudadId,
    items: items,
    fecha: fecha,
  );
}
