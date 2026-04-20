import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/listar_pacientes.dart';
import '../../domain/usecases/registrar_paciente.dart';
import '../../domain/usecases/modificar_paciente.dart';
import '../../domain/repositories/paciente_repository.dart';
import 'paciente_event.dart';
import 'paciente_state.dart';

class PacienteBloc extends Bloc<PacienteEvent, PacienteState> {
  final ListarPacientesUseCase listarPacientesUseCase;
  final RegistrarPacienteUseCase registrarPacienteUseCase;
  final ModificarPacienteUseCase modificarPacienteUseCase;
  final PacienteRepository repository;

  PacienteBloc({
    required this.listarPacientesUseCase,
    required this.registrarPacienteUseCase,
    required this.modificarPacienteUseCase,
    required this.repository,
  }) : super(PacienteInitial()) {
    on<ListarPacientesEvent>(_onListar);
    on<RegistrarPacienteEvent>(_onRegistrar);
    on<ModificarPacienteEvent>(_onModificar);
    on<CargarCiudadesEvent>(_onCargarCiudades);
  }

  Future<void> _onListar(
    ListarPacientesEvent event,
    Emitter<PacienteState> emit,
  ) async {
    emit(PacienteLoading());
    try {
      final pacientes = await listarPacientesUseCase.execute();
      emit(PacientesListados(pacientes));
    } catch (e) {
      emit(PacienteError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegistrar(
    RegistrarPacienteEvent event,
    Emitter<PacienteState> emit,
  ) async {
    emit(PacienteLoading());
    try {
      final resultado = await registrarPacienteUseCase.execute(
        ci: event.ci,
        nombre: event.nombre,
        apellido: event.apellido,
        email: event.email,
        edad: event.edad,
        telefono: event.telefono,
        fechaNacimiento: event.fechaNacimiento,
        ciudadId: event.ciudadId,
      );
      emit(
        PacienteRegistrado(
          email: resultado['credenciales']['email'],
          password: resultado['credenciales']['password'],
        ),
      );
    } catch (e) {
      emit(PacienteError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onModificar(
    ModificarPacienteEvent event,
    Emitter<PacienteState> emit,
  ) async {
    emit(PacienteLoading());
    try {
      await modificarPacienteUseCase.execute(
        id: event.id,
        ci: event.ci,
        edad: event.edad,
        telefono: event.telefono,
        fechaNacimiento: event.fechaNacimiento,
        ciudadId: event.ciudadId,
      );
      emit(PacienteModificado());
    } catch (e) {
      emit(PacienteError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarCiudades(
    CargarCiudadesEvent event,
    Emitter<PacienteState> emit,
  ) async {
    emit(PacienteLoading());
    try {
      final ciudades = await repository.listarCiudades();
      emit(CiudadesCargadas(ciudades));
    } catch (e) {
      emit(PacienteError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
