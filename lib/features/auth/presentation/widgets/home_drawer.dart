import 'package:ciemsi_app/core/di/app_dependencies.dart';
import 'package:ciemsi_app/features/agenda/presentation/pages/agenda_page.dart';
import 'package:ciemsi_app/features/asistentes/presentation/pages/asistentes_page.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/pages/gestionar_qr_page.dart';
import 'package:ciemsi_app/features/cuentas/presentation/pages/cuentas_page.dart';
import 'package:ciemsi_app/features/pagos/presentation/pages/compras_producto_page.dart';
import 'package:ciemsi_app/features/pagos/presentation/pages/productos_page.dart';
import 'package:ciemsi_app/features/servicios/presentation/pages/servicios_page.dart';
import 'package:ciemsi_app/features/suministros/presentation/pages/suministros_page.dart';
import 'package:ciemsi_app/features/traslados/presentation/bloc/traslado_bloc.dart';
import 'package:ciemsi_app/features/traslados/presentation/pages/traslados_page.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/tratamientos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../pacientes/presentation/bloc/paciente_bloc.dart';
import '../../../pacientes/presentation/pages/pacientes_page.dart';
import '../../domain/entities/usuario.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Drawer (menú lateral) del home, con accesos según el rol del usuario.
class HomeDrawer extends StatelessWidget {
  final Usuario usuario;
  final CitaBloc citaBloc;
  final TrasladoBloc trasladoBloc;
  final int? ciudadIdInventario;
  final String? ciudadNombreInventario;

  const HomeDrawer({
    super.key,
    required this.usuario,
    required this.citaBloc,
    required this.trasladoBloc,
    required this.ciudadIdInventario,
    required this.ciudadNombreInventario,
  });

  @override
  Widget build(BuildContext context) {
    final isDoctora = usuario.rol == 'Doctora';
    bool puedeVer(String modulo) =>
        isDoctora || (usuario.permisos[modulo] ?? false);
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
                  usuario.nombreCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  usuario.ciudad != null
                      ? '${usuario.rol} • ${usuario.ciudad!.nombreCiudad}'
                      : usuario.rol,
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
          if (puedeVer('servicios'))
            _drawerTile(
              icon: Icons.medical_services_outlined,
              color: const Color(0xFF00B5C8),
              label: 'Servicios',
              subtitle: 'Catálogo y roles',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => AppDependencies.createServicioBloc(),
                      child: const ServiciosPage(),
                    ),
                  ),
                );
              },
            ),
          if (isDoctora)
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
          if (puedeVer('suministros'))
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
          if (puedeVer('tratamientos'))
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
          if (puedeVer('productos'))
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
          if (puedeVer('compras'))
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
                      ciudadIdInicial: usuario.ciudad?.id,
                      ciudadNombreInicial: usuario.ciudad?.nombreCiudad,
                    ),
                  ),
                );
              },
            ),
          if (puedeVer('qr_pago'))
            _drawerTile(
              icon: Icons.qr_code_2_outlined,
              color: const Color(0xFF8DC63F),
              label: 'QR de pago',
              subtitle: 'Configurar adelanto',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: citaBloc,
                      child: const GestionarQrPage(),
                    ),
                  ),
                );
              },
            ),
          _drawerTile(
            icon: Icons.swap_horiz,
            color: const Color(0xFF00B5C8),
            label: 'Traslados',
            subtitle: 'Entre sucursales',
            onTap: () {
              final ciudadId = usuario.rol == 'Asistente'
                  ? usuario.ciudad?.id
                  : ciudadIdInventario;
              final ciudadNombre = usuario.rol == 'Asistente'
                  ? usuario.ciudad?.nombreCiudad
                  : ciudadNombreInventario;

              Navigator.pop(context);

              if (ciudadId == null || ciudadNombre == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Selecciona una ciudad en Inventario primero',
                    ),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: trasladoBloc,
                    child: TrasladosPage(
                      ciudadId: ciudadId,
                      ciudadNombre: ciudadNombre,
                      usuario: usuario,
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
                    child: AgendaPage(usuario: usuario),
                  ),
                ),
              );
            },
          ),
          if (puedeVer('cuentas'))
            _drawerTile(
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF00B5C8),
              label: 'Cuentas',
              subtitle: 'Caja y banco',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => AppDependencies.createCuentaBloc(),
                      child: const CuentasPage(),
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
