import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/core/di/app_dependencies.dart';
import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_bloc.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_event.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_state.dart';
import 'package:ciemsi_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ciemsi_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:ciemsi_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:ciemsi_app/features/auth/presentation/pages/splash_page.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/pages/citas_page.dart';
import 'package:ciemsi_app/features/historial/presentation/pages/mi_historial_page.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/tratamientos_asignados_page.dart';
import 'package:ciemsi_app/features/pagos/presentation/pages/historial_pagos_paciente_page.dart';

class PacienteHomePage extends StatefulWidget {
  final Usuario usuario;
  const PacienteHomePage({super.key, required this.usuario});

  @override
  State<PacienteHomePage> createState() => _PacienteHomePageState();
}

class _PacienteHomePageState extends State<PacienteHomePage> {
  int _currentIndex = 0;
  late final CitaBloc _citaBloc;
  late final TratamientoBloc _tratamientoBloc;
  late final PagoBloc _pagoBloc;

  @override
  void initState() {
    super.initState();
    _citaBloc = AppDependencies.createCitaBloc();
    _tratamientoBloc = AppDependencies.createTratamientoBloc();
    _pagoBloc = AppDependencies.createPagoBloc();
  }

  @override
  void dispose() {
    _citaBloc.close();
    _tratamientoBloc.close();
    _pagoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _citaBloc),
        BlocProvider.value(value: _tratamientoBloc),
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
        child: Scaffold(
          bottomNavigationBar: _buildBottomNav(),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              CitasPage(usuario: widget.usuario),
              const MiHistorialPage(),
              TratamientosAsignadosPage(puedeGestionar: false),
              const HistorialPagosPacientePage(),
              _PerfilTab(usuario: widget.usuario),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      selectedItemColor: const Color(0xFF00B5C8),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Citas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_outlined),
          activeIcon: Icon(Icons.folder),
          label: 'Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Tratamientos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Mis Pagos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Mi Perfil',
        ),
      ],
    );
  }
}

// ─── Perfil Tab ───────────────────────────────────────────────────────────────

class _PerfilTab extends StatefulWidget {
  final Usuario usuario;
  const _PerfilTab({required this.usuario});

  @override
  State<_PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<_PerfilTab> {
  String _ci = '';
  String _telefono = '';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    context.read<PagoBloc>().add(CargarPerfilCompletoEvent());
  }

  @override
  Widget build(BuildContext context) {
    final esCiValido = _ci.isNotEmpty && !_ci.startsWith('PROV-');
    final ciudad = widget.usuario.ciudad?.nombreCiudad;

    return BlocListener<PagoBloc, PagoState>(
      listener: (context, state) {
        if (state is PerfilCompletoObtenido) {
          setState(() {
            _ci = state.ci;
            _telefono = state.telefono;
            _cargando = false;
          });
        } else if (state is PagoError) {
          setState(() => _cargando = false);
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF00B5C8),
              child: Text(
                widget.usuario.nombre.isNotEmpty
                    ? widget.usuario.nombre[0].toUpperCase()
                    : 'P',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.usuario.nombreCompleto,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00B5C8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00B5C8).withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'Paciente',
                style: TextStyle(
                  color: Color(0xFF00B5C8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: _cargando
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00B5C8),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.email_outlined,
                            'Email',
                            widget.usuario.email,
                          ),
                          if (esCiValido)
                            _buildInfoRow(Icons.badge_outlined, 'CI', _ci),
                          if (_telefono.isNotEmpty)
                            _buildInfoRow(
                              Icons.phone_outlined,
                              'Teléfono',
                              _telefono,
                            ),
                          if (ciudad != null)
                            _buildInfoRow(
                              Icons.location_city_outlined,
                              'Ciudad',
                              ciudad,
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 32),

            // Cerrar sesión
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.read<AuthBloc>().add(CerrarSesionEvent()),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00B5C8), size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
