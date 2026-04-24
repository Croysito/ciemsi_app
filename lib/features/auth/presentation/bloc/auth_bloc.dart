import 'package:ciemsi_app/core/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/iniciar_sesion.dart';
import '../../domain/usecases/recuperar_contrasena.dart';
import '../../domain/usecases/cerrar_sesion.dart';
import '../../domain/entities/usuario.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IniciarSesionUseCase iniciarSesionUseCase;
  final RecuperarContrasenaUseCase recuperarContrasenaUseCase;
  final CerrarSesionUseCase cerrarSesionUseCase;

  AuthBloc({
    required this.iniciarSesionUseCase,
    required this.recuperarContrasenaUseCase,
    required this.cerrarSesionUseCase,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RecuperarContrasenaEvent>(_onRecuperarContrasena);
    on<CerrarSesionEvent>(_onCerrarSesion);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final resultado = await iniciarSesionUseCase.execute(
        event.email,
        event.password,
      );

      // Inicializar notificaciones después del login
      await NotificationService.inicializar();

      emit(
        AuthSuccess(
          usuario: resultado['usuario'] as Usuario,
          token: resultado['token'] as String,
        ),
      );
    } catch (e) {
      emit(AuthError(mensaje: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRecuperarContrasena(
    RecuperarContrasenaEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await recuperarContrasenaUseCase.execute(event.email);
      emit(RecuperarContrasenaSuccess());
    } catch (e) {
      emit(AuthError(mensaje: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCerrarSesion(
    CerrarSesionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await cerrarSesionUseCase.execute();
      emit(CerrarSesionSuccess());
    } catch (e) {
      emit(AuthError(mensaje: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
