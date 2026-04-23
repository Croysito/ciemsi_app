import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ciemsi_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ciemsi_app/features/auth/domain/usecases/iniciar_sesion.dart';
import 'package:ciemsi_app/features/auth/domain/usecases/recuperar_contrasena.dart';
import 'package:ciemsi_app/features/auth/domain/usecases/cerrar_sesion.dart';
import 'package:ciemsi_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ciemsi_app/features/auth/presentation/pages/splash_page.dart';
import 'package:ciemsi_app/features/pacientes/data/datasources/paciente_remote_datasource.dart';
import 'package:ciemsi_app/features/pacientes/data/repositories/paciente_repository_impl.dart';
import 'package:ciemsi_app/features/pacientes/domain/usecases/listar_pacientes.dart';
import 'package:ciemsi_app/features/pacientes/domain/usecases/registrar_paciente.dart';
import 'package:ciemsi_app/features/pacientes/domain/usecases/modificar_paciente.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClientProvider.instance;

    // Auth
    final authDatasource = AuthRemoteDatasource(apiClient);
    final authRepository = AuthRepositoryImpl(authDatasource);

    // Pacientes
    final pacienteDatasource = PacienteRemoteDatasource(apiClient);
    final pacienteRepository = PacienteRepositoryImpl(pacienteDatasource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            iniciarSesionUseCase: IniciarSesionUseCase(authRepository),
            recuperarContrasenaUseCase: RecuperarContrasenaUseCase(
              authRepository,
            ),
            cerrarSesionUseCase: CerrarSesionUseCase(authRepository),
          ),
        ),
        BlocProvider(
          create: (_) => PacienteBloc(
            listarPacientesUseCase: ListarPacientesUseCase(pacienteRepository),
            registrarPacienteUseCase: RegistrarPacienteUseCase(
              pacienteRepository,
            ),
            modificarPacienteUseCase: ModificarPacienteUseCase(
              pacienteRepository,
            ),
            repository: pacienteRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'CIEMSI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B5C8)),
          useMaterial3: true,
        ),
        home: const SplashPage(), // 👈 cambia LoginPage por SplashPage
      ),
    );
  }
}
