import '../repositories/traslado_repository.dart';

class ConfirmarTrasladoUseCase {
  final TrasladoRepository repository;
  ConfirmarTrasladoUseCase(this.repository);

  Future<void> execute(int id) => repository.confirmar(id);
}
