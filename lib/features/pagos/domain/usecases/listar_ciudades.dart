import '../repositories/pago_repository.dart';

class ListarCiudadesUseCase {
  final PagoRepository repository;
  ListarCiudadesUseCase(this.repository);

  Future<List<Map<String, dynamic>>> execute() => repository.listarCiudades();
}
