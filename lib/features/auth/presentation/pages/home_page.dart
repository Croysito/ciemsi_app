import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:ciemsi_app/features/auth/presentation/pages/splash_page.dart';
import 'package:ciemsi_app/features/calendario/presentation/pages/calendario_page.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/traslados/presentation/bloc/traslado_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/tratamientos_asignados_page.dart';
import 'package:ciemsi_app/core/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/usuario.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_dashboard_tab.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_inventario_tab.dart';
import '../widgets/home_pagos_tab.dart';

class HomePage extends StatefulWidget {
  final Usuario usuario;
  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late final CitaBloc _citaBloc;
  late final AgendaBloc _agendaBloc;
  late final TratamientoBloc _tratamientoBloc;
  late final SuministroBloc _suministroBloc;
  late final TrasladoBloc _trasladoBloc;
  late final DashboardBloc _dashboardBloc;
  late final PagoBloc _pagoBloc;

  int? _ciudadIdInventario;
  String? _ciudadNombreInventario;

  // La ciudad de Inventario solo queda "fija" (no reseteable) para un
  // Asistente normal; uno con veTodasCiudades elige ciudad libremente,
  // igual que la Doctora.
  bool get _ciudadInventarioReseteable =>
      widget.usuario.rol != 'Asistente' || widget.usuario.veTodasCiudades;

  @override
  void initState() {
    super.initState();
    _citaBloc = AppDependencies.createCitaBloc();
    _agendaBloc = AppDependencies.createAgendaBloc();
    _tratamientoBloc = AppDependencies.createTratamientoBloc();
    _suministroBloc = AppDependencies.createSuministroBloc();
    _trasladoBloc = AppDependencies.createTrasladoBloc();
    _dashboardBloc = AppDependencies.createDashboardBloc();
    _pagoBloc = AppDependencies.createPagoBloc();

    if (widget.usuario.rol == 'Asistente' &&
        !widget.usuario.veTodasCiudades &&
        widget.usuario.ciudad != null) {
      _ciudadIdInventario = widget.usuario.ciudad!.id;
      _ciudadNombreInventario = widget.usuario.ciudad!.nombreCiudad;
    }
  }

  @override
  void dispose() {
    _citaBloc.close();
    _agendaBloc.close();
    _tratamientoBloc.close();
    _suministroBloc.close();
    _trasladoBloc.close();
    _dashboardBloc.close();
    _pagoBloc.close();
    super.dispose();
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _onBottomNavTap(int i) {
    setState(() {
      if (_currentIndex == 4 && i != 4 && _ciudadInventarioReseteable) {
        _ciudadIdInventario = null;
        _ciudadNombreInventario = null;
      }
      _currentIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _citaBloc),
        BlocProvider.value(value: _agendaBloc),
        BlocProvider.value(value: _tratamientoBloc),
        BlocProvider.value(value: _suministroBloc),
        BlocProvider.value(value: _trasladoBloc),
        BlocProvider.value(value: _dashboardBloc),
        BlocProvider.value(value: _pagoBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is CerrarSesionSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SplashPage()),
              (route) => false,
            );
          }
        },
        child: PopScope(
          canPop: _currentIndex == 2,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (_currentIndex == 4 &&
                _ciudadIdInventario != null &&
                _ciudadInventarioReseteable) {
              setState(() {
                _ciudadIdInventario = null;
                _ciudadNombreInventario = null;
              });
            } else {
              setState(() => _currentIndex = 2);
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            drawer: HomeDrawer(
              usuario: widget.usuario,
              citaBloc: _citaBloc,
              agendaBloc: _agendaBloc,
              trasladoBloc: _trasladoBloc,
              ciudadIdInventario: _ciudadIdInventario,
              ciudadNombreInventario: _ciudadNombreInventario,
            ),
            bottomNavigationBar: HomeBottomNav(
              currentIndex: _currentIndex,
              onTap: _onBottomNavTap,
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: [
                CalendarioPage(usuario: widget.usuario, onMenuTap: _openDrawer),
                PagosTab(usuario: widget.usuario, onMenuTap: _openDrawer),
                DashboardTab(usuario: widget.usuario, onMenuTap: _openDrawer),
                TratamientosAsignadosPage(onMenuTap: _openDrawer),
                InventarioTab(
                  usuario: widget.usuario,
                  onMenuTap: _openDrawer,
                  ciudadId: _ciudadIdInventario,
                  ciudadNombre: _ciudadNombreInventario,
                  suministroBloc: _suministroBloc,
                  trasladoBloc: _trasladoBloc,
                  onCiudadSeleccionada: (id, nombre) => setState(() {
                    _ciudadIdInventario = id;
                    _ciudadNombreInventario = nombre;
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
