import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/cuenta_repository_impl.dart';
import 'cuenta_event.dart';
import 'cuenta_state.dart';

class CuentaBloc extends Bloc<CuentaEvent, CuentaState> {
  final CuentaRepositoryImpl _repo;

  CuentaBloc(this._repo) : super(CuentaInitial()) {
    on<CargarResumenCuentasEvent>(_onCargarResumen);
    on<CargarHistorialEvent>(_onCargarHistorial);
    on<CargarSaldoInicialEvent>(_onCargarSaldoInicial);
    on<SetSaldoInicialEvent>(_onSetSaldoInicial);
    on<RegistrarMovimientoExtraEvent>(_onRegistrar);
    on<EliminarMovimientoExtraEvent>(_onEliminar);
    on<RegistrarTraspasoEvent>(_onRegistrarTraspaso);
    on<EliminarTraspasoEvent>(_onEliminarTraspaso);
  }

  Future<void> _onCargarResumen(CargarResumenCuentasEvent e, Emitter<CuentaState> emit) async {
    emit(CuentaLoading());
    try {
      final data = await _repo.obtenerResumen(ciudadId: e.ciudadId);
      emit(ResumenCuentasCargado(data));
    } catch (ex) {
      emit(CuentaError(ex.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarHistorial(CargarHistorialEvent e, Emitter<CuentaState> emit) async {
    emit(CuentaLoading());
    try {
      final data = await _repo.obtenerHistorial(
        ciudadId: e.ciudadId,
        fechaDesde: e.fechaDesde,
        fechaHasta: e.fechaHasta,
        tipo: e.tipo,
      );
      emit(HistorialCargado(data));
    } catch (ex) {
      emit(CuentaError(ex.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarSaldoInicial(CargarSaldoInicialEvent e, Emitter<CuentaState> emit) async {
    emit(CuentaLoading());
    try {
      final data = await _repo.obtenerSaldoInicial(e.ciudadId);
      emit(SaldoInicialCargado(caja: data['caja'] ?? 0, banco: data['banco'] ?? 0));
    } catch (ex) {
      emit(CuentaError(ex.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSetSaldoInicial(SetSaldoInicialEvent e, Emitter<CuentaState> emit) async {
    emit(CuentaLoading());
    try {
      await _repo.setSaldoInicial(ciudadId: e.ciudadId, tipo: e.tipo, monto: e.monto);
      emit(SaldoInicialActualizado());
    } catch (ex) {
      emit(CuentaError(ex.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegistrar(RegistrarMovimientoExtraEvent e, Emitter<CuentaState> emit) async {
    emit(CuentaLoading());
    try {
      await _repo.registrarMovimientoExtra(
        tipo: e.tipo,
        categoria: e.categoria,
        descripcion: e.descripcion,
        monto: e.monto,
        metodo: e.metodo,
        ciudadId: e.ciudadId,
      );
      emit(MovimientoExtraRegistrado());
    } catch (ex) {
      emit(CuentaError(ex.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onEliminar(EliminarMovimientoExtraEvent e, Emitter<CuentaState> emit) async {
    try {
      await _repo.eliminarMovimientoExtra(e.id);
      emit(MovimientoExtraEliminado());
    } catch (ex) {
      emit(CuentaError(ex.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegistrarTraspaso(RegistrarTraspasoEvent e, Emitter<CuentaState> emit) async {
    emit(CuentaLoading());
    try {
      await _repo.registrarTraspaso(
        tipo: e.tipo,
        monto: e.monto,
        descripcion: e.descripcion,
        ciudadId: e.ciudadId,
      );
      emit(TraspasoRegistrado());
    } catch (ex) {
      emit(CuentaError(ex.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onEliminarTraspaso(EliminarTraspasoEvent e, Emitter<CuentaState> emit) async {
    try {
      await _repo.eliminarTraspaso(e.id);
      emit(TraspasoEliminado());
    } catch (ex) {
      emit(CuentaError(ex.toString().replaceAll('Exception: ', '')));
    }
  }
}
