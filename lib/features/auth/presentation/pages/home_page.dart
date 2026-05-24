import 'package:ciemsi_app/features/agenda/presentation/pages/agenda_page.dart';
import 'package:ciemsi_app/features/auth/presentation/pages/splash_page.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/pages/citas_page.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/pages/inventario_page.dart';
import 'package:ciemsi_app/features/traslados/presentation/bloc/traslado_bloc.dart';
import 'package:ciemsi_app/features/traslados/presentation/pages/traslados_page.dart';
import 'package:ciemsi_app/features/suministros/presentation/pages/suministros_page.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/tratamientos_asignados_page.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/tratamientos_page.dart';
import 'package:ciemsi_app/features/pagos/presentation/pages/productos_page.dart';
import 'package:ciemsi_app/features/pagos/presentation/pages/compras_producto_page.dart';
import 'package:ciemsi_app/features/pagos/presentation/pages/estado_cuenta_page.dart';
import 'package:ciemsi_app/core/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../pacientes/presentation/bloc/paciente_bloc.dart';
import '../../domain/entities/usuario.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../pacientes/presentation/pages/pacientes_page.dart';
import 'package:ciemsi_app/features/asistentes/presentation/pages/asistentes_page.dart';
import 'package:ciemsi_app/features/auth/presentation/bloc/dashboard_bloc.dart';
import 'package:ciemsi_app/features/auth/presentation/bloc/dashboard_event.dart';
import 'package:ciemsi_app/features/auth/presentation/bloc/dashboard_state.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_bloc.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_event.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_state.dart';
import '../../../pacientes/presentation/bloc/paciente_event.dart';
import '../../../pacientes/presentation/bloc/paciente_state.dart';
import '../../../pacientes/domain/entities/paciente.dart';

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
  late final TratamientoBloc _tratamientoBloc;
  late final SuministroBloc _suministroBloc;
  late final TrasladoBloc _trasladoBloc;
  late final DashboardBloc _dashboardBloc;
  late final PagoBloc _pagoBloc;

  int? _ciudadIdInventario;
  String? _ciudadNombreInventario;

  @override
  void initState() {
    super.initState();
    _citaBloc = AppDependencies.createCitaBloc();
    _tratamientoBloc = AppDependencies.createTratamientoBloc();
    _suministroBloc = AppDependencies.createSuministroBloc();
    _trasladoBloc = AppDependencies.createTrasladoBloc();
    _dashboardBloc = AppDependencies.createDashboardBloc();
    _pagoBloc = AppDependencies.createPagoBloc();

    if (widget.usuario.rol == 'Asistente' && widget.usuario.ciudad != null) {
      _ciudadIdInventario = widget.usuario.ciudad!.id;
      _ciudadNombreInventario = widget.usuario.ciudad!.nombreCiudad;
    }
  }

  @override
  void dispose() {
    _citaBloc.close();
    _tratamientoBloc.close();
    _suministroBloc.close();
    _trasladoBloc.close();
    _dashboardBloc.close();
    _pagoBloc.close();
    super.dispose();
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _citaBloc),
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
                widget.usuario.rol != 'Asistente') {
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
            drawer: _buildDrawer(context),
            bottomNavigationBar: _buildBottomNav(),
            body: IndexedStack(
              index: _currentIndex,
              children: [
                CitasPage(usuario: widget.usuario, onMenuTap: _openDrawer),
                _PagosTab(usuario: widget.usuario, onMenuTap: _openDrawer),
                _DashboardTab(usuario: widget.usuario, onMenuTap: _openDrawer),
                TratamientosAsignadosPage(onMenuTap: _openDrawer),
                _InventarioTab(
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() {
        if (_currentIndex == 4 && i != 4 && widget.usuario.rol != 'Asistente') {
          _ciudadIdInventario = null;
          _ciudadNombreInventario = null;
        }
        _currentIndex = i;
      }),
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
          icon: Icon(Icons.payments_outlined),
          activeIcon: Icon(Icons.payments),
          label: 'Pagos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Tratamientos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Inventario',
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDoctora = widget.usuario.rol == 'Doctora';
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF00B5C8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.usuario.nombreCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  widget.usuario.ciudad != null
                      ? '${widget.usuario.rol} • ${widget.usuario.ciudad!.nombreCiudad}'
                      : widget.usuario.rol,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _drawerTile(
            icon: Icons.people_outlined,
            color: const Color(0xFF00B5C8),
            label: 'Pacientes',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<PacienteBloc>(),
                    child: const PacientesPage(),
                  ),
                ),
              );
            },
          ),
          if (isDoctora) ...[
            _drawerTile(
              icon: Icons.badge_outlined,
              color: const Color(0xFF8DC63F),
              label: 'Asistentes',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => AppDependencies.createAsistenteBloc(),
                      child: const AsistentesPage(),
                    ),
                  ),
                );
              },
            ),
            _drawerTile(
              icon: Icons.medication_outlined,
              color: const Color(0xFF00B5C8),
              label: 'Suministros',
              subtitle: 'Catálogo',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => AppDependencies.createSuministroBloc(),
                      child: const SuministrosPage(),
                    ),
                  ),
                );
              },
            ),
            _drawerTile(
              icon: Icons.healing_outlined,
              color: Colors.purple,
              label: 'Tratamientos',
              subtitle: 'Catálogo',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => AppDependencies.createTratamientoBloc(),
                      child: const TratamientosPage(),
                    ),
                  ),
                );
              },
            ),
            _drawerTile(
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFF8DC63F),
              label: 'Productos',
              subtitle: 'Catálogo',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductosPage()),
                );
              },
            ),
            _drawerTile(
              icon: Icons.add_shopping_cart_outlined,
              color: const Color(0xFF00B5C8),
              label: 'Compras',
              subtitle: 'Productos comprados',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComprasProductoPage(
                      ciudadIdInicial: widget.usuario.ciudad?.id,
                      ciudadNombreInicial: widget.usuario.ciudad?.nombreCiudad,
                    ),
                  ),
                );
              },
            ),
          ],
          _drawerTile(
            icon: Icons.swap_horiz,
            color: const Color(0xFF00B5C8),
            label: 'Traslados',
            subtitle: 'Entre sucursales',
            onTap: () {
              final ciudadId = widget.usuario.rol == 'Asistente'
                  ? widget.usuario.ciudad?.id
                  : _ciudadIdInventario;
              final ciudadNombre = widget.usuario.rol == 'Asistente'
                  ? widget.usuario.ciudad?.nombreCiudad
                  : _ciudadNombreInventario;

              Navigator.pop(context);

              if (ciudadId == null || ciudadNombre == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selecciona una ciudad en Inventario primero'),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: _trasladoBloc,
                    child: TrasladosPage(
                      ciudadId: ciudadId,
                      ciudadNombre: ciudadNombre,
                      usuario: widget.usuario,
                    ),
                  ),
                ),
              );
            },
          ),
          _drawerTile(
            icon: Icons.calendar_month_outlined,
            color: const Color(0xFF8DC63F),
            label: 'Agenda',
            subtitle: 'Configurar horarios',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => AppDependencies.createAgendaBloc(),
                    child: AgendaPage(usuario: widget.usuario),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _drawerTile(
            icon: Icons.logout,
            color: Colors.red,
            label: 'Cerrar sesión',
            textColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(CerrarSesionEvent());
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required Color color,
    required String label,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: textColor)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 11))
          : null,
      onTap: onTap,
    );
  }
}

// ─── Dashboard ────────────────────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback onMenuTap;

  const _DashboardTab({required this.usuario, required this.onMenuTap});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    context.read<DashboardBloc>().add(
      CargarDashboardEvent(ciudadId: widget.usuario.ciudad?.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hora = DateTime.now().hour;
    final saludo = hora < 12
        ? 'Buenos días'
        : hora < 19
        ? 'Buenas tardes'
        : 'Buenas noches';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: widget.onMenuTap,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inicio',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              DateFormat('EEEE d \'de\' MMMM', 'es').format(DateTime.now()),
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00B5C8),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          final citasHoy = state is DashboardCargado
              ? state.citasHoy
              : <Map<String, dynamic>>[];
          final cumpleaneros = state is DashboardCargado
              ? state.cumpleaneros
              : <Map<String, dynamic>>[];
          final alertasStock = state is DashboardCargado
              ? state.alertasStock
              : <Map<String, dynamic>>[];
          return RefreshIndicator(
            onRefresh: () async => _cargarDatos(),
            color: const Color(0xFF00B5C8),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '$saludo, ${widget.usuario.nombre}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.usuario.ciudad != null
                      ? '${widget.usuario.rol} • ${widget.usuario.ciudad!.nombreCiudad}'
                      : widget.usuario.rol,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                if (cumpleaneros.isNotEmpty) ...[
                  _CardCumpleanos(pacientes: cumpleaneros),
                  const SizedBox(height: 12),
                ],
                if (alertasStock.isNotEmpty) ...[
                  _CardAlertas(alertas: alertasStock),
                  const SizedBox(height: 12),
                ],
                _CardCitasHoy(citas: citasHoy),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CardCumpleanos extends StatelessWidget {
  final List<Map<String, dynamic>> pacientes;
  const _CardCumpleanos({required this.pacientes});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.pink.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🎂', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  pacientes.length == 1
                      ? 'Cumpleaños hoy'
                      : 'Cumpleaños hoy (${pacientes.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...pacientes.map((p) {
              final usuario = p['usuario'] as Map<String, dynamic>?;
              final nombre = usuario != null
                  ? '${usuario['nombre']} ${usuario['apellido']}'
                  : 'Paciente';
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 15,
                      color: Colors.pink,
                    ),
                    const SizedBox(width: 6),
                    Text(nombre, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CardAlertas extends StatelessWidget {
  final List<Map<String, dynamic>> alertas;
  const _CardAlertas({required this.alertas});

  @override
  Widget build(BuildContext context) {
    final mostradas = alertas.take(3).toList();
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock bajo (${alertas.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...mostradas.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${a['nombre_suministro']} — ${a['saldo']} ${a['unidad_medida']}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (alertas.length > 3)
              Text(
                '+${alertas.length - 3} más',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardCitasHoy extends StatelessWidget {
  final List<Map<String, dynamic>> citas;
  const _CardCitasHoy({required this.citas});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF00B5C8),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  citas.isEmpty
                      ? 'Sin citas hoy'
                      : 'Citas de hoy (${citas.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (citas.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No hay citas programadas para hoy.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              )
            else ...[
              const SizedBox(height: 10),
              ...citas.map((c) {
                final hora = c['hora']?.toString().substring(0, 5) ?? '';
                final paciente =
                    c['paciente']?['nombreCompleto']?.toString() ?? 'Paciente';
                final servicio =
                    c['servicio']?['nombreServicio']?.toString() ?? '';
                final ciudad = c['ciudad']?['nombreCiudad']?.toString() ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B5C8).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          hora,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00B5C8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paciente,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            if (servicio.isNotEmpty || ciudad.isNotEmpty)
                              Text(
                                [
                                  servicio,
                                  ciudad,
                                ].where((s) => s.isNotEmpty).join(' • '),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Pagos Tab ────────────────────────────────────────────────────────────────

class _PagosTab extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback onMenuTap;

  const _PagosTab({required this.usuario, required this.onMenuTap});

  @override
  State<_PagosTab> createState() => _PagosTabState();
}

class _PagosTabState extends State<_PagosTab> {
  final _searchController = TextEditingController();
  List<Paciente> _todos = [];
  List<Paciente> _filtrados = [];
  Map<int, double> _deudas = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrar);
    _cargar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargar() {
    setState(() => _cargando = true);
    context.read<PacienteBloc>().add(ListarPacientesEvent());
    context.read<PagoBloc>().add(CargarResumenDeudasEvent());
  }

  void _filtrar() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? _todos
          : _todos.where((p) {
              return p.nombreCompleto.toLowerCase().contains(q) ||
                  p.ci.toLowerCase().contains(q);
            }).toList();
    });
  }

  void _abrirEstadoCuenta(Paciente paciente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EstadoCuentaPage(
          pacienteId: paciente.id,
          ciudadId: paciente.ciudad?.id ?? 0,
          nombrePaciente: paciente.nombreCompleto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: widget.onMenuTap,
        ),
        title: const Text(
          'Pagos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargar,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PacienteBloc, PacienteState>(
            listener: (context, state) {
              if (state is PacientesListados) {
                setState(() {
                  _todos = state.pacientes;
                  _cargando = false;
                });
                _filtrar();
              } else if (state is PacienteError) {
                setState(() => _cargando = false);
              }
            },
          ),
          BlocListener<PagoBloc, PagoState>(
            listener: (context, state) {
              if (state is ResumenDeudasCargado) {
                setState(() => _deudas = state.deudas);
                _filtrar();
              }
            },
          ),
        ],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar paciente por nombre o CI...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF00B5C8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B5C8),
                      ),
                    )
                  : _filtrados.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'No hay pacientes registrados'
                                : 'Sin resultados para "${_searchController.text}"',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: _filtrados.length,
                          itemBuilder: (_, i) {
                            final p = _filtrados[i];
                            final deuda = _deudas[p.id];
                            final tieneDeuda = deuda != null && deuda > 0;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: tieneDeuda ? Colors.red.shade50 : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: tieneDeuda
                                      ? Colors.red.shade100
                                      : const Color(0xFFE0F7FA),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: tieneDeuda
                                        ? Colors.red.shade700
                                        : const Color(0xFF00B5C8),
                                  ),
                                ),
                                title: Text(
                                  p.nombreCompleto,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  p.ciudad?.nombreCiudad != null
                                      ? 'CI: ${p.ci}  •  ${p.ciudad!.nombreCiudad}'
                                      : 'CI: ${p.ci}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: tieneDeuda
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade600,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Bs. ${NumberFormat('#,##0.00', 'es').format(deuda)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                onTap: () => _abrirEstadoCuenta(p),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Inventario Tab ───────────────────────────────────────────────────────────

class _InventarioTab extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onMenuTap;
  final int? ciudadId;
  final String? ciudadNombre;
  final SuministroBloc suministroBloc;
  final TrasladoBloc trasladoBloc;
  final void Function(int, String) onCiudadSeleccionada;

  const _InventarioTab({
    required this.usuario,
    required this.onMenuTap,
    required this.ciudadId,
    required this.ciudadNombre,
    required this.suministroBloc,
    required this.trasladoBloc,
    required this.onCiudadSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    if (ciudadId != null && ciudadNombre != null) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: suministroBloc),
          BlocProvider.value(value: trasladoBloc),
        ],
        child: InventarioPage(
          ciudadId: ciudadId!,
          ciudadNombre: ciudadNombre!,
          onMenuTap: onMenuTap,
          usuario: usuario,
        ),
      );
    }

    // Doctora: selector de ciudad
    return _SelectorCiudadInventario(
      onMenuTap: onMenuTap,
      onSeleccionada: onCiudadSeleccionada,
    );
  }
}

class _SelectorCiudadInventario extends StatefulWidget {
  final VoidCallback onMenuTap;
  final void Function(int, String) onSeleccionada;

  const _SelectorCiudadInventario({
    required this.onMenuTap,
    required this.onSeleccionada,
  });

  @override
  State<_SelectorCiudadInventario> createState() =>
      _SelectorCiudadInventarioState();
}

class _SelectorCiudadInventarioState extends State<_SelectorCiudadInventario> {
  List<Map<String, dynamic>> _ciudades = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    context.read<PagoBloc>().add(CargarCiudadesPagoEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PagoBloc, PagoState>(
      listener: (context, state) {
        if (state is CiudadesPagoCargadas) {
          setState(() {
            _ciudades = state.ciudades;
            _cargando = false;
          });
        } else if (state is PagoError) {
          setState(() => _cargando = false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: widget.onMenuTap,
          ),
          title: const Text(
            'Inventario',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF00B5C8),
        ),
        body: _cargando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Selecciona una ciudad',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _ciudades.length,
                      itemBuilder: (_, i) {
                        final c = _ciudades[i];
                        final id = c['id'] is int
                            ? c['id'] as int
                            : int.tryParse(c['id'].toString());
                        final nombre =
                            c['nombreCiudad']?.toString() ?? 'Sin nombre';
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.location_city_outlined,
                              color: Color(0xFF00B5C8),
                            ),
                            title: Text(nombre),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: id != null
                                ? () => widget.onSeleccionada(id, nombre)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
