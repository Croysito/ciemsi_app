import 'package:ciemsi_app/features/agenda/presentation/pages/agenda_page.dart';
import 'package:ciemsi_app/features/auth/presentation/pages/splash_page.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/pages/citas_page.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/pages/inventario_page.dart';
import 'package:ciemsi_app/features/suministros/presentation/pages/suministros_page.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/tratamientos_asignados_page.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/tratamientos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../pacientes/presentation/bloc/paciente_bloc.dart';
import '../../domain/entities/usuario.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../pacientes/presentation/pages/pacientes_page.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_bloc.dart';
import 'package:ciemsi_app/features/asistentes/presentation/pages/asistentes_page.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';

class HomePage extends StatefulWidget {
  final Usuario usuario;
  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late final CitaBloc _citaBloc;
  late final TratamientoBloc _tratamientoBloc;
  late final SuministroBloc _suministroBloc;

  int? _ciudadIdInventario;
  String? _ciudadNombreInventario;

  @override
  void initState() {
    super.initState();
    _citaBloc = CitaBloc();
    _tratamientoBloc = TratamientoBloc();
    _suministroBloc = SuministroBloc();

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
          key: _scaffoldKey,
          drawer: _buildDrawer(context),
          bottomNavigationBar: _buildBottomNav(),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              CitasPage(usuario: widget.usuario, onMenuTap: _openDrawer),
              _DashboardTab(usuario: widget.usuario, onMenuTap: _openDrawer),
              TratamientosAsignadosPage(onMenuTap: _openDrawer),
              _InventarioTab(
                usuario: widget.usuario,
                onMenuTap: _openDrawer,
                ciudadId: _ciudadIdInventario,
                ciudadNombre: _ciudadNombreInventario,
                suministroBloc: _suministroBloc,
                onCiudadSeleccionada: (id, nombre) => setState(() {
                  _ciudadIdInventario = id;
                  _ciudadNombreInventario = nombre;
                }),
              ),
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
                      create: (_) => AsistenteBloc(),
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
                      create: (_) => SuministroBloc(),
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
                      create: (_) => TratamientoBloc(),
                      child: const TratamientosPage(),
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
                  MaterialPageRoute(builder: (_) => const AgendaPage()),
                );
              },
            ),
          ],
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
  bool _cargando = true;
  List<Map<String, dynamic>> _citasHoy = [];
  List<Map<String, dynamic>> _cumpleanos = [];
  List<Map<String, dynamic>> _alertasStock = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    setState(() => _cargando = true);
    await Future.wait([_cargarCitas(), _cargarCumpleanos(), _cargarAlertas()]);
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _cargarCitas() async {
    try {
      final res = await ApiClientProvider.instance.dio.get('/citas');
      final hoy = DateTime.now();
      _citasHoy = (res.data as List)
          .cast<Map<String, dynamic>>()
          .where((c) {
            final f = DateTime.tryParse(c['fecha']?.toString() ?? '');
            return f != null &&
                f.year == hoy.year &&
                f.month == hoy.month &&
                f.day == hoy.day;
          })
          .toList()
        ..sort((a, b) {
          final ha = a['hora']?.toString() ?? '';
          final hb = b['hora']?.toString() ?? '';
          return ha.compareTo(hb);
        });
    } catch (_) {}
  }

  Future<void> _cargarCumpleanos() async {
    try {
      final res = await ApiClientProvider.instance.dio.get('/pacientes');
      final hoy = DateTime.now();
      _cumpleanos = (res.data as List)
          .cast<Map<String, dynamic>>()
          .where((p) {
            final fn = DateTime.tryParse(p['fechaNacimiento']?.toString() ?? '');
            return fn != null && fn.month == hoy.month && fn.day == hoy.day;
          })
          .toList();
    } catch (_) {}
  }

  Future<void> _cargarAlertas() async {
    try {
      final ciudad = widget.usuario.ciudad;
      if (ciudad == null) return;
      final res = await ApiClientProvider.instance.dio.get(
        '/suministros/alertas',
        queryParameters: {'ciudadId': ciudad.id},
      );
      _alertasStock = ((res.data['stockBajo'] as List?) ?? [])
          .cast<Map<String, dynamic>>();
    } catch (_) {}
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
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            )
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              color: const Color(0xFF00B5C8),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Saludo
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

                  // Cumpleaños
                  if (_cumpleanos.isNotEmpty) ...[
                    _CardCumpleanos(pacientes: _cumpleanos),
                    const SizedBox(height: 12),
                  ],

                  // Alertas de stock
                  if (_alertasStock.isNotEmpty) ...[
                    _CardAlertas(alertas: _alertasStock),
                    const SizedBox(height: 12),
                  ],

                  // Citas de hoy
                  _CardCitasHoy(citas: _citasHoy),
                ],
              ),
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
                    const Icon(Icons.person_outline,
                        size: 15, color: Colors.pink),
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
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 20),
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
            ...mostradas.map((a) => Padding(
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
            )),
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
                const Icon(Icons.calendar_today,
                    color: Color(0xFF00B5C8), size: 18),
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
                final paciente = c['paciente']?['nombreCompleto']?.toString() ??
                    'Paciente';
                final servicio =
                    c['servicio']?['nombreServicio']?.toString() ?? '';
                final ciudad =
                    c['ciudad']?['nombreCiudad']?.toString() ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
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
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            if (servicio.isNotEmpty || ciudad.isNotEmpty)
                              Text(
                                [servicio, ciudad]
                                    .where((s) => s.isNotEmpty)
                                    .join(' • '),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11),
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

// ─── Inventario Tab ───────────────────────────────────────────────────────────

class _InventarioTab extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onMenuTap;
  final int? ciudadId;
  final String? ciudadNombre;
  final SuministroBloc suministroBloc;
  final void Function(int, String) onCiudadSeleccionada;

  const _InventarioTab({
    required this.usuario,
    required this.onMenuTap,
    required this.ciudadId,
    required this.ciudadNombre,
    required this.suministroBloc,
    required this.onCiudadSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    if (ciudadId != null && ciudadNombre != null) {
      return BlocProvider.value(
        value: suministroBloc,
        child: InventarioPage(
          ciudadId: ciudadId!,
          ciudadNombre: ciudadNombre!,
          onMenuTap: onMenuTap,
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

class _SelectorCiudadInventarioState
    extends State<_SelectorCiudadInventario> {
  List<Map<String, dynamic>> _ciudades = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final res = await ApiClientProvider.instance.dio.get('/ciudades');
      if (mounted) {
        setState(() {
          _ciudades = (res.data as List).cast<Map<String, dynamic>>();
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
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
          'Inventario',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Selecciona una ciudad',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.location_city_outlined,
                              color: Color(0xFF00B5C8)),
                          title: Text(nombre),
                          trailing:
                              const Icon(Icons.chevron_right),
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
    );
  }
}
