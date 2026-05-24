import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';
import '../bloc/traslado_bloc.dart';
import '../bloc/traslado_event.dart';
import '../bloc/traslado_state.dart';
import '../../domain/entities/traslado.dart';
import 'crear_traslado_page.dart';

class TrasladosPage extends StatefulWidget {
  final int ciudadId;
  final String ciudadNombre;
  final Usuario usuario;

  const TrasladosPage({
    super.key,
    required this.ciudadId,
    required this.ciudadNombre,
    required this.usuario,
  });

  @override
  State<TrasladosPage> createState() => _TrasladosPageState();
}

class _TrasladosPageState extends State<TrasladosPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cargar() =>
      context.read<TrasladoBloc>().add(ListarTrasladosEvent(widget.ciudadId));

  bool get _esAdminODoctora =>
      widget.usuario.rol == 'Doctora' || widget.usuario.rol == 'Admin';

  bool _puedeConfirmar(Traslado t) {
    if (_esAdminODoctora) return true;
    return widget.usuario.rol == 'Asistente' &&
        widget.usuario.ciudad?.id == t.ciudadDestinoId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          'Traslados — ${widget.ciudadNombre}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargar,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.hourglass_top_outlined), text: 'Pendientes'),
            Tab(icon: Icon(Icons.history),                text: 'Historial'),
          ],
        ),
      ),
      floatingActionButton: _esAdminODoctora
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF00B5C8),
              onPressed: _abrirCrear,
              icon: const Icon(Icons.swap_horiz, color: Colors.white),
              label: const Text('Nuevo Traslado',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
      body: BlocConsumer<TrasladoBloc, TrasladoState>(
        listener: (context, state) {
          if (state is TrasladoOperacionExitosa) _cargar();
          if (state is TrasladoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is TrasladoLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          if (state is TrasladoError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.mensaje, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _cargar, child: const Text('Reintentar')),
                ],
              ),
            );
          }
          if (state is TrasladosListados) {
            final pendientes = state.traslados.where((t) => t.isPendiente).toList();
            final historial  = state.traslados.where((t) => !t.isPendiente).toList();
            return TabBarView(
              controller: _tabController,
              children: [
                _ListaTraslados(
                  traslados: pendientes,
                  emptyMsg: 'Sin traslados pendientes',
                  onConfirmar: (t) => _puedeConfirmar(t)
                      ? context.read<TrasladoBloc>().add(
                            ConfirmarTrasladoEvent(t.id, widget.ciudadId))
                      : null,
                  onDevolver: null,
                  ciudadId: widget.ciudadId,
                ),
                _ListaTraslados(
                  traslados: historial,
                  emptyMsg: 'Sin traslados en el historial',
                  onConfirmar: null,
                  onDevolver: (t) => t.isCompletado
                      ? context.read<TrasladoBloc>().add(
                            DevolverTrasladoEvent(t.id, widget.ciudadId))
                      : null,
                  ciudadId: widget.ciudadId,
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Future<void> _abrirCrear() async {
    final creado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TrasladoBloc>(),
          child: CrearTrasladoPage(
            ciudadOrigenId:     widget.ciudadId,
            ciudadOrigenNombre: widget.ciudadNombre,
          ),
        ),
      ),
    );
    if (creado == true && mounted) _cargar();
  }
}

// ─── Lista ────────────────────────────────────────────────────────────────────

class _ListaTraslados extends StatelessWidget {
  final List<Traslado> traslados;
  final String emptyMsg;
  final void Function(Traslado)? onConfirmar;
  final void Function(Traslado)? onDevolver;
  final int ciudadId;

  const _ListaTraslados({
    required this.traslados,
    required this.emptyMsg,
    required this.onConfirmar,
    required this.onDevolver,
    required this.ciudadId,
  });

  @override
  Widget build(BuildContext context) {
    if (traslados.isEmpty) {
      return Center(child: Text(emptyMsg, style: const TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: traslados.length,
      itemBuilder: (_, i) => _TrasladoCard(
        traslado: traslados[i],
        ciudadId: ciudadId,
        onConfirmar: onConfirmar != null ? () => onConfirmar!(traslados[i]) : null,
        onDevolver:  onDevolver  != null && traslados[i].isCompletado
            ? () => onDevolver!(traslados[i])
            : null,
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _TrasladoCard extends StatelessWidget {
  final Traslado traslado;
  final int ciudadId;
  final VoidCallback? onConfirmar;
  final VoidCallback? onDevolver;

  const _TrasladoCard({
    required this.traslado,
    required this.ciudadId,
    this.onConfirmar,
    this.onDevolver,
  });

  Color get _estadoColor {
    return switch (traslado.estado) {
      'PENDIENTE'  => Colors.orange,
      'COMPLETADO' => const Color(0xFF8DC63F),
      _            => Colors.grey,
    };
  }

  String get _estadoLabel {
    return switch (traslado.estado) {
      'PENDIENTE'  => 'Pendiente',
      'COMPLETADO' => 'Completado',
      _            => 'Devuelto',
    };
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final esSalida = traslado.ciudadOrigenId == ciudadId;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  esSalida ? Icons.arrow_upward : Icons.arrow_downward,
                  color: esSalida ? Colors.orange : const Color(0xFF00B5C8),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    traslado.nombreItem,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _estadoColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _estadoLabel,
                    style: TextStyle(color: _estadoColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.swap_horiz, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${traslado.nombreCiudadOrigen} → ${traslado.nombreCiudadDestino}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cantidad: ${traslado.cantidad % 1 == 0 ? traslado.cantidad.toInt() : traslado.cantidad}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  fmt.format(traslado.fecha.toLocal()),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Por: ${traslado.nombreUsuario}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (onConfirmar != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8DC63F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onConfirmar,
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: const Text('Confirmar recepción',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
            if (onDevolver != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _confirmarDevolucion(context),
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Devolver'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmarDevolucion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar devolución'),
        content: Text(
          '¿Devolver "${traslado.nombreItem}" de ${traslado.nombreCiudadDestino} a ${traslado.nombreCiudadOrigen}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
              onDevolver?.call();
            },
            child: const Text('Devolver'),
          ),
        ],
      ),
    );
  }
}
