import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/asistentes/data/datasources/asistente_remote_datasource.dart';
import 'package:ciemsi_app/features/asistentes/data/repositories/asistente_repository_impl.dart';
import 'package:ciemsi_app/features/asistentes/domain/usecases/cambiar_estado_asistente.dart';
import 'package:ciemsi_app/features/asistentes/domain/usecases/cambiar_password_asistente.dart';
import 'package:ciemsi_app/features/asistentes/domain/usecases/crear_asistente.dart';
import 'package:ciemsi_app/features/asistentes/domain/usecases/listar_asistentes.dart';
import 'package:ciemsi_app/features/asistentes/domain/usecases/listar_ciudades_asistente.dart';
import 'package:ciemsi_app/features/asistentes/domain/usecases/modificar_asistente.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_bloc.dart';
import 'package:ciemsi_app/features/citas/data/datasources/cita_remote_datasource.dart';
import 'package:ciemsi_app/features/citas/data/repositories/cita_repository_impl.dart';
import 'package:ciemsi_app/features/citas/domain/usecases/cambiar_estado_cita.dart';
import 'package:ciemsi_app/features/citas/domain/usecases/listar_citas.dart';
import 'package:ciemsi_app/features/citas/domain/usecases/listar_servicios_cita.dart';
import 'package:ciemsi_app/features/citas/domain/usecases/modificar_cita.dart';
import 'package:ciemsi_app/features/citas/domain/usecases/obtener_horas_disponibles.dart';
import 'package:ciemsi_app/features/citas/domain/usecases/reservar_cita.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/suministros/data/datasources/suministro_remote_datasource.dart';
import 'package:ciemsi_app/features/suministros/data/repositories/suministro_repository_impl.dart';
import 'package:ciemsi_app/features/suministros/domain/usecases/crear_suministro.dart';
import 'package:ciemsi_app/features/suministros/domain/usecases/listar_suministros.dart';
import 'package:ciemsi_app/features/suministros/domain/usecases/obtener_alertas_suministro.dart';
import 'package:ciemsi_app/features/suministros/domain/usecases/obtener_inventario.dart';
import 'package:ciemsi_app/features/suministros/domain/usecases/registrar_compra.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/data/datasources/tratamiento_remote_datasource.dart';
import 'package:ciemsi_app/features/tratamientos/data/repositories/tratamiento_repository_impl.dart';
import 'package:ciemsi_app/features/tratamientos/domain/usecases/agregar_suministro_tratamiento.dart';
import 'package:ciemsi_app/features/tratamientos/domain/usecases/asignar_tratamiento.dart';
import 'package:ciemsi_app/features/tratamientos/domain/usecases/completar_tratamiento.dart';
import 'package:ciemsi_app/features/tratamientos/domain/usecases/crear_tratamiento.dart';
import 'package:ciemsi_app/features/tratamientos/domain/usecases/generar_receta_tratamiento.dart';
import 'package:ciemsi_app/features/tratamientos/domain/usecases/listar_tratamientos.dart';
import 'package:ciemsi_app/features/tratamientos/domain/usecases/listar_tratamientos_asignados.dart';
import 'package:ciemsi_app/features/tratamientos/domain/usecases/listar_tratamientos_asignados_by_cita.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/pagos/data/datasources/pago_remote_datasource.dart';
import 'package:ciemsi_app/features/pagos/data/repositories/pago_repository_impl.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/obtener_estado_cuenta.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/registrar_cobro_deuda.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/registrar_venta_producto.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/listar_productos.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/listar_inventario_productos.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/crear_producto.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/modificar_producto.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/cambiar_estado_producto.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/listar_compras_producto.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/registrar_compra_producto.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/listar_ciudades.dart';
import 'package:ciemsi_app/features/pagos/domain/usecases/obtener_mi_perfil_paciente.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_bloc.dart';
import 'package:ciemsi_app/features/traslados/data/datasources/traslado_remote_datasource.dart';
import 'package:ciemsi_app/features/traslados/data/repositories/traslado_repository_impl.dart';
import 'package:ciemsi_app/features/traslados/domain/usecases/listar_traslados.dart';
import 'package:ciemsi_app/features/traslados/domain/usecases/crear_traslado.dart';
import 'package:ciemsi_app/features/traslados/domain/usecases/confirmar_traslado.dart';
import 'package:ciemsi_app/features/traslados/domain/usecases/consultar_stock_traslado.dart';
import 'package:ciemsi_app/features/traslados/domain/usecases/devolver_traslado.dart';
import 'package:ciemsi_app/features/traslados/domain/usecases/obtener_datos_creacion_traslado.dart';
import 'package:ciemsi_app/features/traslados/presentation/bloc/traslado_bloc.dart';
import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:ciemsi_app/features/recetas/presentation/bloc/receta_bloc.dart';
import 'package:ciemsi_app/features/auth/presentation/bloc/dashboard_bloc.dart';

class AppDependencies {
  const AppDependencies._();

  static CitaBloc createCitaBloc() {
    final datasource = CitaRemoteDatasource(ApiClientProvider.instance);
    final repository = CitaRepositoryImpl(datasource);

    return CitaBloc(
      listarCitasUseCase: ListarCitasUseCase(repository),
      reservarCitaUseCase: ReservarCitaUseCase(repository),
      modificarCitaUseCase: ModificarCitaUseCase(repository),
      cambiarEstadoCitaUseCase: CambiarEstadoCitaUseCase(repository),
      listarServiciosCitaUseCase: ListarServiciosCitaUseCase(repository),
      obtenerHorasDisponiblesUseCase: ObtenerHorasDisponiblesUseCase(
        repository,
      ),
    );
  }

  static AsistenteBloc createAsistenteBloc() {
    final datasource = AsistenteRemoteDatasource(ApiClientProvider.instance);
    final repository = AsistenteRepositoryImpl(datasource);

    return AsistenteBloc(
      listarAsistentesUseCase: ListarAsistentesUseCase(repository),
      crearAsistenteUseCase: CrearAsistenteUseCase(repository),
      modificarAsistenteUseCase: ModificarAsistenteUseCase(repository),
      cambiarEstadoAsistenteUseCase: CambiarEstadoAsistenteUseCase(repository),
      cambiarPasswordAsistenteUseCase: CambiarPasswordAsistenteUseCase(
        repository,
      ),
      listarCiudadesUseCase: ListarCiudadesAsistenteUseCase(repository),
    );
  }

  static SuministroBloc createSuministroBloc() {
    final datasource = SuministroRemoteDatasource(ApiClientProvider.instance);
    final repository = SuministroRepositoryImpl(datasource);

    return SuministroBloc(
      listarSuministrosUseCase: ListarSuministrosUseCase(repository),
      crearSuministroUseCase: CrearSuministroUseCase(repository),
      obtenerInventarioUseCase: ObtenerInventarioUseCase(repository),
      obtenerAlertasSuministroUseCase: ObtenerAlertasSuministroUseCase(
        repository,
      ),
      registrarCompraUseCase: RegistrarCompraUseCase(repository),
    );
  }

  static TratamientoBloc createTratamientoBloc() {
    final datasource = TratamientoRemoteDatasource(ApiClientProvider.instance);
    final repository = TratamientoRepositoryImpl(datasource);
    final suministroDatasource = SuministroRemoteDatasource(ApiClientProvider.instance);
    final suministroRepository = SuministroRepositoryImpl(suministroDatasource);

    return TratamientoBloc(
      listarTratamientosUseCase: ListarTratamientosUseCase(repository),
      crearTratamientoUseCase: CrearTratamientoUseCase(repository),
      asignarTratamientoUseCase: AsignarTratamientoUseCase(repository),
      listarAsignadosUseCase: ListarTratamientosAsignadosUseCase(repository),
      listarAsignadosByCitaUseCase: ListarTratamientosAsignadosByCitaUseCase(
        repository,
      ),
      agregarSuministroUseCase: AgregarSuministroTratamientoUseCase(repository),
      completarTratamientoUseCase: CompletarTratamientoUseCase(repository),
      generarRecetaUseCase: GenerarRecetaTratamientoUseCase(repository),
      listarSuministrosUseCase: ListarSuministrosUseCase(suministroRepository),
    );
  }

  static TrasladoBloc createTrasladoBloc() {
    final datasource = TrasladoRemoteDatasource(ApiClientProvider.instance);
    final repository = TrasladoRepositoryImpl(datasource);
    return TrasladoBloc(
      listarUseCase: ListarTrasladosUseCase(repository),
      crearUseCase: CrearTrasladoUseCase(repository),
      confirmarUseCase: ConfirmarTrasladoUseCase(repository),
      devolverUseCase: DevolverTrasladoUseCase(repository),
      obtenerDatosCreacionUseCase: ObtenerDatosCreacionTrasladoUseCase(
        repository,
      ),
      consultarStockUseCase: ConsultarStockTrasladoUseCase(repository),
    );
  }

  static AgendaBloc createAgendaBloc() {
    return AgendaBloc();
  }

  static RecetaBloc createRecetaBloc() {
    return RecetaBloc();
  }

  static DashboardBloc createDashboardBloc() {
    return DashboardBloc();
  }

  static PagoBloc createPagoBloc() {
    final datasource = PagoRemoteDatasource(ApiClientProvider.instance);
    final repository = PagoRepositoryImpl(datasource);
    return PagoBloc(
      obtenerEstadoCuentaUseCase: ObtenerEstadoCuentaUseCase(repository),
      registrarCobroDeudaUseCase: RegistrarCobroDeudaUseCase(repository),
      registrarVentaProductoUseCase: RegistrarVentaProductoUseCase(repository),
      listarProductosUseCase: ListarProductosUseCase(repository),
      listarInventarioProductosUseCase: ListarInventarioProductosUseCase(
        repository,
      ),
      crearProductoUseCase: CrearProductoUseCase(repository),
      modificarProductoUseCase: ModificarProductoUseCase(repository),
      cambiarEstadoProductoUseCase: CambiarEstadoProductoUseCase(repository),
      listarComprasProductoUseCase: ListarComprasProductoUseCase(repository),
      registrarCompraProductoUseCase: RegistrarCompraProductoUseCase(
        repository,
      ),
      listarCiudadesUseCase: ListarCiudadesUseCase(repository),
      obtenerMiPerfilPacienteUseCase: ObtenerMiPerfilPacienteUseCase(repository),
    );
  }
}
