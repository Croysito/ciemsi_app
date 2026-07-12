import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/usuario.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

/// Pestaña "Inicio" del home: saludo, cumpleaños, alertas de stock y citas del día.
class DashboardTab extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback onMenuTap;

  const DashboardTab({
    super.key,
    required this.usuario,
    required this.onMenuTap,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
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
                  saludo,
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
