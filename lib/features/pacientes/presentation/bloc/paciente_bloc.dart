import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/listar_pacientes.dart';
import '../../domain/usecases/listar_ciudades.dart';
import '../../domain/usecases/registrar_paciente.dart';
import '../../domain/usecases/modificar_paciente.dart';
import '../../domain/usecases/completar_paciente.dart';
import 'paciente_event.dart';
import 'paciente_state.dart';

class PacienteBloc extends Bloc<PacienteEvent, PacienteState> {
  final ListarPacientesUseCase listarPacientesUseCase;
  final ListarCiudadesUseCase listarCiudadesUseCase;
  final RegistrarPacienteUseCase registrarPacienteUseCase;
  final ModificarPacienteUseCase modificarPacienteUseCase;
  final CompletarPacienteUseCase completarPacienteUseCase;

  PacienteBloc({
    required this.listarPacientesUseCase,
    required this.listarCiudadesUseCase,
    required this.registrarPacienteUseCase,
    required this.modificarPacienteUseCase,
    required this.completarPacienteUseCase,
  }) : super(PacienteInitial()) {
    on<ListarPacientesEvent>(_onListar);
    on<RegistrarPacienteEvent>(_onRegistrar);
    on<ModificarPacienteEvent>(_onModificar);
    on<CargarCiudadesEvent>(_onCargarCiudades);
    on<CompletarPacienteEvent>(_onCompletar);
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
        telefono: event.telefono,
        fechaNacimiento: event.fechaNacimiento,
        genero: event.genero,
        ciudadId: event.ciudadId,
      );
      emit(
        PacienteRegistrado(
          email: resultado.email,
          password: resultado.password,
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
        nombre: event.nombre,
        apellido: event.apellido,
        email: event.email,
        telefono: event.telefono,
        fechaNacimiento: event.fechaNacimiento,
        genero: event.genero,
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
      final ciudades = await listarCiudadesUseCase.execute();
      emit(CiudadesCargadas(ciudades));
    } catch (e) {
      emit(PacienteError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCompletar(
    CompletarPacienteEvent event,
    Emitter<PacienteState> emit,
  ) async {
    emit(PacienteLoading());
    try {
      await completarPacienteUseCase.execute(
        id: event.id,
        ci: event.ci,
        nombre: event.nombre,
        apellido: event.apellido,
        email: event.email,
        telefono: event.telefono,
        fechaNacimiento: event.fechaNacimiento,
        genero: event.genero,
        ciudadId: event.ciudadId,
      );
      emit(PacienteCompletado());
    } catch (e) {
      emit(PacienteError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
