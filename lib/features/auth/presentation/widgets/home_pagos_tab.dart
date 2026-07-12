import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_bloc.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_event.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_state.dart';
import 'package:ciemsi_app/features/pagos/presentation/pages/estado_cuenta_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../pacientes/domain/entities/paciente.dart';
import '../../../pacientes/presentation/bloc/paciente_bloc.dart';
import '../../../pacientes/presentation/bloc/paciente_event.dart';
import '../../../pacientes/presentation/bloc/paciente_state.dart';
import '../../domain/entities/usuario.dart';

/// Pestaña "Pagos" del home: buscador de pacientes y su estado de deuda.
class PagosTab extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback onMenuTap;

  const PagosTab({super.key, required this.usuario, required this.onMenuTap});

  @override
  State<PagosTab> createState() => _PagosTabState();
}

class _PagosTabState extends State<PagosTab> {
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

  Future<void> _abrirEstadoCuenta(Paciente paciente) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EstadoCuentaPage(
          pacienteId: paciente.id,
          ciudadId: paciente.ciudad?.id ?? 0,
          nombrePaciente: paciente.nombreCompleto,
        ),
      ),
    );
    if (mounted) {
      context.read<PagoBloc>().add(CargarResumenDeudasEvent());
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
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF00B5C8),
                  ),
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
                                      borderRadius: BorderRadius.circular(20),
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
