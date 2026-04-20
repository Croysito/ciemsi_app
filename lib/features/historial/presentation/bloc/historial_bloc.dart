import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/historial_repository.dart';
import '../../domain/usecases/obtener_historial.dart';
import '../../domain/usecases/agregar_nota.dart';
import '../../domain/usecases/agregar_link.dart';
import '../../domain/usecases/subir_archivo_drive.dart';
import 'historial_event.dart';
import 'historial_state.dart';

class HistorialBloc extends Bloc<HistorialEvent, HistorialState> {
  final ObtenerHistorialUseCase obtenerHistorialUseCase;
  final AgregarNotaUseCase agregarNotaUseCase;
  final AgregarLinkUseCase agregarLinkUseCase;
  final SubirArchivoDriveUseCase subirArchivoDriveUseCase;
  final HistorialRepository repository;

  HistorialBloc({
    required this.repository,
    required this.obtenerHistorialUseCase,
    required this.agregarNotaUseCase,
    required this.agregarLinkUseCase,
    required this.subirArchivoDriveUseCase,
  }) : super(HistorialInitial()) {
    on<ObtenerHistorialEvent>(_onObtener);
    on<AgregarNotaEvent>(_onAgregarNota);
    on<AgregarLinkEvent>(_onAgregarLink);
    on<SubirArchivoDriveEvent>(_onSubirArchivo);
    on<ObtenerMiHistorialEvent>(_onObtenerMiHistorial);
  }

  Future<void> _onObtener(
    ObtenerHistorialEvent event,
    Emitter<HistorialState> emit,
  ) async {
    emit(HistorialLoading());
    try {
      final historial = await obtenerHistorialUseCase.execute(event.pacienteId);
      emit(HistorialObtenido(historial));
    } catch (e) {
      emit(HistorialError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAgregarNota(
    AgregarNotaEvent event,
    Emitter<HistorialState> emit,
  ) async {
    emit(HistorialLoading());
    try {
      final nota = await agregarNotaUseCase.execute(
        event.pacienteId,
        event.detalle,
      );
      emit(NotaAgregada(nota));
    } catch (e) {
      emit(HistorialError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAgregarLink(
    AgregarLinkEvent event,
    Emitter<HistorialState> emit,
  ) async {
    emit(HistorialLoading());
    try {
      final link = await agregarLinkUseCase.execute(
        notaId: event.notaId,
        nombre: event.nombre,
        link: event.link,
        tipo: event.tipo,
      );
      emit(LinkAgregado(link));
    } catch (e) {
      emit(HistorialError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSubirArchivo(
    SubirArchivoDriveEvent event,
    Emitter<HistorialState> emit,
  ) async {
    emit(HistorialLoading());
    try {
      final link = await subirArchivoDriveUseCase.execute(
        notaId: event.notaId,
        tipo: event.tipo,
        tokens: event.tokens,
        bytes: event.bytes,
        nombre: event.nombre,
        mimeType: event.mimeType,
      );
      emit(ArchivoSubido(link));
    } catch (e) {
      emit(HistorialError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onObtenerMiHistorial(
    ObtenerMiHistorialEvent event,
    Emitter<HistorialState> emit,
  ) async {
    emit(HistorialLoading());
    try {
      final historial = await repository.obtenerMiHistorial();
      emit(HistorialObtenido(historial));
    } catch (e) {
      emit(HistorialError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
