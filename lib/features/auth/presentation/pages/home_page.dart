import 'package:ciemsi_app/features/agenda/presentation/pages/agenda_page.dart';
import 'package:ciemsi_app/features/auth/presentation/pages/splash_page.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/pages/citas_page.dart';
import 'package:ciemsi_app/features/historial/presentation/pages/mi_historial_page.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/pages/inventario_page.dart';
import 'package:ciemsi_app/features/suministros/presentation/pages/suministros_page.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/tratamientos_asignados_page.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/tratamientos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../pacientes/presentation/bloc/paciente_bloc.dart';
import '../../domain/entities/usuario.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../pacientes/presentation/pages/pacientes_page.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_bloc.dart';
import 'package:ciemsi_app/features/asistentes/presentation/pages/asistentes_page.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';

class HomePage extends StatelessWidget {
  final Usuario usuario;
  const HomePage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'CIEMSI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        actions: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is CerrarSesionSuccess) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashPage()),
                  (route) => false,
                );
              }
            },
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () =>
                  context.read<AuthBloc>().add(CerrarSesionEvent()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, ${usuario.nombreCompleto}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rol: ${usuario.rol}${usuario.ciudad != null ? ' • ${usuario.ciudad!.nombreCiudad}' : ''}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Mostrar módulos según rol
              if (usuario.rol == 'Doctora') ...[
                _buildModulo(
                  context,
                  icon: Icons.people_outlined,
                  titulo: 'Pacientes',
                  subtitulo: 'Gestionar pacientes e historiales',
                  color: const Color(0xFF00B5C8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<PacienteBloc>(),
                        child: const PacientesPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildModulo(
                  context,
                  icon: Icons.badge_outlined,
                  titulo: 'Asistentes',
                  subtitulo: 'Gestionar asistentes por ciudad',
                  color: const Color(0xFF8DC63F),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => AsistenteBloc(),
                        child: const AsistentesPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildModulo(
                  context,
                  icon: Icons.calendar_month_outlined,
                  titulo: 'Agenda',
                  subtitulo: 'Configurar horarios por ciudad',
                  color: const Color(0xFF8DC63F),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AgendaPage()),
                  ),
                ),
                const SizedBox(height: 12),
                _buildModulo(
                  context,
                  icon: Icons.calendar_month_outlined,
                  titulo: 'Citas',
                  subtitulo: 'Gestionar citas médicas',
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => CitaBloc(),
                        child: CitasPage(usuario: usuario),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildModulo(
                  context,
                  icon: Icons.medication_outlined,
                  titulo: 'Suministros',
                  subtitulo: 'Gestionar catálogo de suministros',
                  color: const Color(0xFF00B5C8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => SuministroBloc(),
                        child: const SuministrosPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 👇 Inventario para la Doctora - selecciona ciudad
                _buildModulo(
                  context,
                  icon: Icons.inventory_outlined,
                  titulo: 'Inventario',
                  subtitulo: 'Ver inventario y registrar compras',
                  color: const Color(0xFF8DC63F),
                  onTap: () => _seleccionarCiudadInventario(context),
                ),
                const SizedBox(height: 12),
                _buildModulo(
                  context,
                  icon: Icons.healing_outlined,
                  titulo: 'Tratamientos',
                  subtitulo: 'Gestionar catálogo de tratamientos',
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => TratamientoBloc(),
                        child: const TratamientosPage(),
                      ),
                    ),
                  ),
                ),
              ] else if (usuario.rol == 'Asistente') ...[
                _buildModulo(
                  context,
                  icon: Icons.people_outlined,
                  titulo: 'Pacientes',
                  subtitulo: 'Ver pacientes de tu ciudad',
                  color: const Color(0xFF00B5C8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<PacienteBloc>(),
                        child: const PacientesPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildModulo(
                  context,
                  icon: Icons.calendar_month_outlined,
                  titulo: 'Citas',
                  subtitulo: 'Gestionar citas de tu ciudad',
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => CitaBloc(),
                        child: CitasPage(usuario: usuario),
                      ),
                    ),
                  ),
                ),
                _buildModulo(
                  context,
                  icon: Icons.healing_outlined,
                  titulo: 'Tratamientos',
                  subtitulo: 'Ver y aplicar tratamientos asignados',
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => TratamientoBloc(),
                        child: const TratamientosAsignadosPage(),
                      ),
                    ),
                  ),
                ),
                _buildModulo(
                  context,
                  icon: Icons.inventory_outlined,
                  titulo: 'Inventario',
                  subtitulo: 'Ver inventario de tu ciudad',
                  color: const Color(0xFF8DC63F),
                  onTap: () => _abrirInventarioAsistente(context),
                ),
              ] else if (usuario.rol == 'Paciente') ...[
                _buildModulo(
                  context,
                  icon: Icons.history,
                  titulo: 'Mi Historial',
                  subtitulo: 'Ver mis notas, imágenes y videos',
                  color: const Color(0xFF00B5C8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MiHistorialPage()),
                  ),
                ),
                _buildModulo(
                  context,
                  icon: Icons.calendar_month_outlined,
                  titulo: 'Mis Citas',
                  subtitulo: 'Ver y reservar citas',
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => CitaBloc(),
                        child: CitasPage(usuario: usuario),
                      ),
                    ),
                  ),
                ),
                _buildModulo(
                  context,
                  icon: Icons.healing_outlined,
                  titulo: 'Tratamientos',
                  subtitulo: 'Ver mis tratamientos asignados',
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => TratamientoBloc(),
                        child: const TratamientosAsignadosPage(
                          puedeGestionar: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModulo(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _seleccionarCiudadInventario(BuildContext context) async {
    try {
      final response = await ApiClientProvider.instance.dio.get('/ciudades');
      final ciudades = (response.data as List)
          .whereType<Map<String, dynamic>>()
          .toList();

      if (!context.mounted) return;

      if (ciudades.isEmpty) {
        _mostrarMensaje(context, 'No hay ciudades disponibles');
        return;
      }

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona una ciudad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 320,
                child: ListView.builder(
                  itemCount: ciudades.length,
                  itemBuilder: (_, index) {
                    final ciudad = ciudades[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_city_outlined,
                        color: Color(0xFF00B5C8),
                      ),
                      title: Text(
                        ciudad['nombreCiudad']?.toString() ?? 'Sin nombre',
                      ),
                      onTap: () {
                        final ciudadId = _intValue(ciudad['id']);
                        if (ciudadId == null) {
                          Navigator.pop(sheetContext);
                          _mostrarMensaje(
                            context,
                            'La ciudad no tiene un ID válido',
                          );
                          return;
                        }

                        Navigator.pop(sheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => SuministroBloc(),
                              child: InventarioPage(
                                ciudadId: ciudadId,
                                ciudadNombre:
                                    ciudad['nombreCiudad']?.toString() ??
                                    'Sin nombre',
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error cargando ciudades: $e');
      if (!context.mounted) return;
      _mostrarMensaje(context, 'No se pudieron cargar las ciudades');
    }
  }

  void _abrirInventarioAsistente(BuildContext context) {
    final ciudad = usuario.ciudad;
    if (ciudad == null) {
      _mostrarMensaje(context, 'Tu usuario no tiene una ciudad asignada');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => SuministroBloc(),
          child: InventarioPage(
            ciudadId: ciudad.id,
            ciudadNombre: ciudad.nombreCiudad,
          ),
        ),
      ),
    );
  }

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.orange),
    );
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
