import 'package:ciemsi_app/features/tratamientos/domain/entities/tratamiento_asignado.dart';
import 'package:ciemsi_app/features/suministros/domain/usecases/listar_suministros.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/agregar_suministro_tratamiento.dart';
import '../../domain/usecases/asignar_tratamiento.dart';
import '../../domain/usecases/completar_tratamiento.dart';
import '../../domain/usecases/crear_tratamiento.dart';
import '../../domain/usecases/generar_receta_tratamiento.dart';
import '../../domain/usecases/listar_tratamientos.dart';
import '../../domain/usecases/listar_tratamientos_asignados.dart';
import '../../domain/usecases/listar_tratamientos_asignados_by_cita.dart';
import 'tratamiento_event.dart';
import 'tratamiento_state.dart';

class TratamientoBloc extends Bloc<TratamientoEvent, TratamientoState> {
  final ListarTratamientosUseCase listarTratamientosUseCase;
  final CrearTratamientoUseCase crearTratamientoUseCase;
  final AsignarTratamientoUseCase asignarTratamientoUseCase;
  final ListarTratamientosAsignadosUseCase listarAsignadosUseCase;
  final ListarTratamientosAsignadosByCitaUseCase listarAsignadosByCitaUseCase;
  final AgregarSuministroTratamientoUseCase agregarSuministroUseCase;
  final CompletarTratamientoUseCase completarTratamientoUseCase;
  final GenerarRecetaTratamientoUseCase generarRecetaUseCase;
  final ListarSuministrosUseCase listarSuministrosUseCase;

  TratamientoBloc({
    required this.listarTratamientosUseCase,
    required this.crearTratamientoUseCase,
    required this.asignarTratamientoUseCase,
    required this.listarAsignadosUseCase,
    required this.listarAsignadosByCitaUseCase,
    required this.agregarSuministroUseCase,
    required this.completarTratamientoUseCase,
    required this.generarRecetaUseCase,
    required this.listarSuministrosUseCase,
  }) : super(TratamientoInitial()) {
    on<ListarTratamientosEvent>(_onListar);
    on<CrearTratamientoEvent>(_onCrear);
    on<AsignarTratamientoEvent>(_onAsignar);
    on<ListarAsignadosEvent>(_onListarAsignados);
    on<ListarAsignadosByCitaEvent>(_onListarAsignadosByCita);
    on<AgregarSuministroEvent>(_onAgregarSuministro);
    on<AgregarMultiplesSuministrosEvent>(_onAgregarMultiples);
    on<CompletarTratamientoEvent>(_onCompletar);
    on<GenerarRecetaEvent>(_onGenerarReceta);
    on<CargarMedicamentosEvent>(_onCargarMedicamentos);
  }

  Future<void> _onListar(
    ListarTratamientosEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      final tratamientos = await listarTratamientosUseCase.execute();
      emit(TratamientosListados(tratamientos));
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCrear(
    CrearTratamientoEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      await crearTratamientoUseCase.execute(
        nombreTratamiento: event.nombreTratamiento,
        detalle: event.detalle,
        precioBase: event.precioBase,
        medicamentosBase: event.medicamentosBase,
      );
      emit(TratamientoCreado());
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAsignar(
    AsignarTratamientoEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      await asignarTratamientoUseCase.execute(
        tratamientoId: event.tratamientoId,
        citaId: event.citaId,
        precio: event.precio,
        medicamentos: event.medicamentos,
      );
      emit(TratamientoAsignadoExito());
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onListarAsignados(
    ListarAsignadosEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      final List<TratamientoAsignado> tratamientos =
          await listarAsignadosUseCase.execute();
      emit(TratamientosAsignadosListados(tratamientos));
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onListarAsignadosByCita(
    ListarAsignadosByCitaEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      final List<TratamientoAsignado> tratamientos =
          await listarAsignadosByCitaUseCase.execute(event.citaId);
      emit(TratamientosAsignadosListados(tratamientos));
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAgregarSuministro(
    AgregarSuministroEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      await agregarSuministroUseCase.execute(
        tratamientoAsignadoId: event.tratamientoAsignadoId,
        suministroId: event.suministroId,
        cantidad: event.cantidad,
      );
      emit(SuministroAgregado());
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAgregarMultiples(
    AgregarMultiplesSuministrosEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      for (final item in event.items) {
        await agregarSuministroUseCase.execute(
          tratamientoAsignadoId: event.tratamientoAsignadoId,
          suministroId: item['suministroId'] as int,
          cantidad: item['cantidad'] as int,
        );
      }
      emit(SuministroAgregado());
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCompletar(
    CompletarTratamientoEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      await completarTratamientoUseCase.execute(event.id);
      emit(TratamientoCompletado());
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGenerarReceta(
    GenerarRecetaEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    emit(TratamientoLoading());
    try {
      final receta = await generarRecetaUseCase.execute(
        citaId: event.citaId,
        detalle: event.detalle,
      );
      emit(RecetaGenerada(receta));
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarMedicamentos(
    CargarMedicamentosEvent event,
    Emitter<TratamientoState> emit,
  ) async {
    try {
      final medicamentos = await listarSuministrosUseCase.execute(
        tipo: 'MEDICAMENTO',
      );
      emit(MedicamentosCargados(medicamentos));
    } catch (e) {
      emit(TratamientoError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
