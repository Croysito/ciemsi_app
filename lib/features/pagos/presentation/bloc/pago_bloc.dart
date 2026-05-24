import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/obtener_estado_cuenta.dart';
import '../../domain/usecases/registrar_cobro_deuda.dart';
import '../../domain/usecases/registrar_venta_producto.dart';
import '../../domain/usecases/listar_productos.dart';
import '../../domain/usecases/listar_inventario_productos.dart';
import '../../domain/usecases/crear_producto.dart';
import '../../domain/usecases/modificar_producto.dart';
import '../../domain/usecases/cambiar_estado_producto.dart';
import '../../domain/usecases/listar_compras_producto.dart';
import '../../domain/usecases/registrar_compra_producto.dart';
import '../../domain/usecases/listar_ciudades.dart';
import '../../domain/usecases/obtener_mi_perfil_paciente.dart';
import 'pago_event.dart';
import 'pago_state.dart';

class PagoBloc extends Bloc<PagoEvent, PagoState> {
  final ObtenerEstadoCuentaUseCase obtenerEstadoCuentaUseCase;
  final RegistrarCobroDeudaUseCase registrarCobroDeudaUseCase;
  final RegistrarVentaProductoUseCase registrarVentaProductoUseCase;
  final ListarProductosUseCase listarProductosUseCase;
  final ListarInventarioProductosUseCase listarInventarioProductosUseCase;
  final CrearProductoUseCase crearProductoUseCase;
  final ModificarProductoUseCase modificarProductoUseCase;
  final CambiarEstadoProductoUseCase cambiarEstadoProductoUseCase;
  final ListarComprasProductoUseCase listarComprasProductoUseCase;
  final RegistrarCompraProductoUseCase registrarCompraProductoUseCase;
  final ListarCiudadesUseCase listarCiudadesUseCase;
  final ObtenerMiPerfilPacienteUseCase obtenerMiPerfilPacienteUseCase;

  PagoBloc({
    required this.obtenerEstadoCuentaUseCase,
    required this.registrarCobroDeudaUseCase,
    required this.registrarVentaProductoUseCase,
    required this.listarProductosUseCase,
    required this.listarInventarioProductosUseCase,
    required this.crearProductoUseCase,
    required this.modificarProductoUseCase,
    required this.cambiarEstadoProductoUseCase,
    required this.listarComprasProductoUseCase,
    required this.registrarCompraProductoUseCase,
    required this.listarCiudadesUseCase,
    required this.obtenerMiPerfilPacienteUseCase,
  }) : super(PagoInitial()) {
    on<ObtenerEstadoCuentaEvent>(_onObtenerEstadoCuenta);
    on<RegistrarCobroDeudaEvent>(_onRegistrarCobroDeuda);
    on<RegistrarVentaProductoEvent>(_onRegistrarVentaProducto);
    on<ListarProductosEvent>(_onListarProductos);
    on<ListarInventarioProductosEvent>(_onListarInventarioProductos);
    on<CrearProductoEvent>(_onCrearProducto);
    on<ModificarProductoEvent>(_onModificarProducto);
    on<CambiarEstadoProductoEvent>(_onCambiarEstadoProducto);
    on<ListarComprasProductoEvent>(_onListarComprasProducto);
    on<RegistrarCompraProductoEvent>(_onRegistrarCompraProducto);
    on<CargarCiudadesPagoEvent>(_onCargarCiudades);
    on<CargarMiPerfilPacienteEvent>(_onCargarMiPerfilPaciente);
    on<CargarResumenDeudasEvent>(_onCargarResumenDeudas);
    on<CargarPerfilCompletoEvent>(_onCargarPerfilCompleto);
  }

  Future<void> _onObtenerEstadoCuenta(
    ObtenerEstadoCuentaEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      final ec = await obtenerEstadoCuentaUseCase.execute(event.pacienteId);
      emit(EstadoCuentaObtenido(ec));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegistrarCobroDeuda(
    RegistrarCobroDeudaEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      final ingreso = await registrarCobroDeudaUseCase.execute(
        deudaId: event.deudaId,
        pacienteId: event.pacienteId,
        ciudadId: event.ciudadId,
        monto: event.monto,
        metodo: event.metodo,
        notas: event.notas,
      );
      emit(IngresoRegistrado(ingreso));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegistrarVentaProducto(
    RegistrarVentaProductoEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      final ingreso = await registrarVentaProductoUseCase.execute(
        pacienteId: event.pacienteId,
        ciudadId: event.ciudadId,
        items: event.items,
        metodo: event.metodo,
        notas: event.notas,
      );
      emit(IngresoRegistrado(ingreso));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onListarProductos(
    ListarProductosEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      final productos = await listarProductosUseCase.execute();
      emit(ProductosListados(productos));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onListarInventarioProductos(
    ListarInventarioProductosEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      final items = await listarInventarioProductosUseCase.execute(
        event.ciudadId,
      );
      emit(InventarioProductosListado(items));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCrearProducto(
    CrearProductoEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      final producto = await crearProductoUseCase.execute(
        nombre: event.nombre,
        descripcion: event.descripcion,
        unidadMedida: event.unidadMedida,
        precioVenta: event.precioVenta,
        umbral: event.umbral,
      );
      emit(ProductoOperacionExitosa(producto: producto));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onModificarProducto(
    ModificarProductoEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      await modificarProductoUseCase.execute(
        id: event.id,
        nombre: event.nombre,
        descripcion: event.descripcion,
        unidadMedida: event.unidadMedida,
        precioVenta: event.precioVenta,
        umbral: event.umbral,
        estado: event.estado,
      );
      emit(ProductoOperacionExitosa());
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCambiarEstadoProducto(
    CambiarEstadoProductoEvent event,
    Emitter<PagoState> emit,
  ) async {
    try {
      await cambiarEstadoProductoUseCase.execute(event.id);
      emit(ProductoOperacionExitosa());
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onListarComprasProducto(
    ListarComprasProductoEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      final compras = await listarComprasProductoUseCase.execute(
        ciudadId: event.ciudadId,
      );
      emit(ComprasProductoListadas(compras));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegistrarCompraProducto(
    RegistrarCompraProductoEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      await registrarCompraProductoUseCase.execute(
        ciudadId: event.ciudadId,
        fecha: event.fecha,
        items: event.items,
      );
      emit(CompraProductoRegistrada());
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarCiudades(
    CargarCiudadesPagoEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      final ciudades = await listarCiudadesUseCase.execute();
      emit(CiudadesPagoCargadas(ciudades));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarMiPerfilPaciente(
    CargarMiPerfilPacienteEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      final perfil = await obtenerMiPerfilPacienteUseCase.execute();
      final id = perfil['id'];
      final pacienteId = id is int ? id : int.tryParse(id.toString());
      if (pacienteId == null) {
        emit(PagoError('No se pudo obtener el perfil del paciente'));
        return;
      }
      emit(MiPerfilPacienteCargado(pacienteId));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarResumenDeudas(
    CargarResumenDeudasEvent event,
    Emitter<PagoState> emit,
  ) async {
    try {
      final res = await ApiClientProvider.instance.dio.get(
        '/deudas/resumen-pendientes',
      );
      final deudas = <int, double>{
        for (final d in (res.data as List).cast<Map<String, dynamic>>())
          (d['pacienteId'] is int
                  ? d['pacienteId'] as int
                  : int.tryParse(d['pacienteId'].toString()) ?? 0):
              (d['totalPendiente'] as num).toDouble(),
      };
      emit(ResumenDeudasCargado(deudas));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCargarPerfilCompleto(
    CargarPerfilCompletoEvent event,
    Emitter<PagoState> emit,
  ) async {
    emit(PagoLoading());
    try {
      final perfil = await obtenerMiPerfilPacienteUseCase.execute();
      final id = perfil['id'];
      final pacienteId = id is int ? id : int.tryParse(id.toString()) ?? 0;
      final ci = perfil['ci']?.toString() ?? '';
      final telefono = perfil['telefono']?.toString() ?? '';
      emit(PerfilCompletoObtenido(pacienteId: pacienteId, ci: ci, telefono: telefono));
    } catch (e) {
      emit(PagoError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
