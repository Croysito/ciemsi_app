import 'package:ciemsi_app/features/auth/presentation/pages/splash_page.dart';
import 'package:ciemsi_app/features/historial/presentation/pages/mi_historial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../pacientes/presentation/bloc/paciente_bloc.dart';
import '../../domain/entities/usuario.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import '../../../pacientes/presentation/pages/pacientes_page.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_bloc.dart';
import 'package:ciemsi_app/features/asistentes/presentation/pages/asistentes_page.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, ${usuario.nombreCompleto}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            ] else if (usuario.rol == 'Asistente') ...[
              _buildModulo(
                context,
                icon: Icons.people_outlined,
                titulo: 'Pacientes',
                subtitulo: 'Ver pacientes e historiales',
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
            ],
          ],
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
}
