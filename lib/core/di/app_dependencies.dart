import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/asistentes/data/datasources/asistente_remote_datasource.dart';
import 'package:ciemsi_app/features/asistentes/data/repositories/asistente_repository_impl.dart';
import 'package:ciemsi_app/features/asistentes/domain/usecases/cambiar_estado_asistente.dart';
import 'package:ciemsi_app/features/asistentes/domain/usecases/cambiar_password_asistente.dart';
import 'package:ciemsi_app/features/asistentes/domain/usecases/crear_asistente.dart';
import 'package:ciemsi_app/features/asistentes/domain/usecases/listar_asistentes.dart';
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
    );
  }
}
