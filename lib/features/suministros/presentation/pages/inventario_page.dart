import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/core/di/app_dependencies.dart';
import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';
import 'package:ciemsi_app/features/pagos/domain/entities/producto_inventario_item.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_bloc.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_event.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_state.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_event.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_state.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/inventario_item.dart';
import 'package:ciemsi_app/features/pagos/presentation/pages/compras_producto_page.dart';
import 'package:ciemsi_app/features/traslados/presentation/bloc/traslado_bloc.dart';
import 'package:ciemsi_app/features/traslados/presentation/pages/crear_traslado_page.dart';
import 'registrar_compra_page.dart';

class InventarioPage extends StatefulWidget {
  final int ciudadId;
  final String ciudadNombre;
  final VoidCallback? onMenuTap;
  final Usuario? usuario;

  const InventarioPage({
    super.key,
    required this.ciudadId,
    required this.ciudadNombre,
    this.onMenuTap,
    this.usuario,
  });

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<SuministroBloc>().add(ObtenerInventarioEvent(widget.ciudadId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        leading: widget.onMenuTap != null
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: widget.onMenuTap,
              )
            : null,
        title: Text(
          'Inventario - ${widget.ciudadNombre}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_tabController.index == 0) {
                context.read<SuministroBloc>().add(
                  ObtenerInventarioEvent(widget.ciudadId),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.warning_outlined),
            onPressed: () => _mostrarAlertas(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.medication_outlined), text: 'Suministros'),
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Productos'),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (_, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'fab_compra',
              backgroundColor: const Color(0xFF8DC63F),
              onPressed: _tabController.index == 0
                  ? _abrirComprasSuministros
                  : _abrirComprasProductos,
              child: const Icon(Icons.add_shopping_cart, color: Colors.white),
            ),
            if (widget.usuario != null) ...[
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'fab_traslado',
                backgroundColor: const Color(0xFF00B5C8),
                onPressed: _abrirTraslado,
                child: const Icon(Icons.swap_horiz, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TabSuministros(ciudadId: widget.ciudadId),
          _TabProductos(ciudadId: widget.ciudadId),
        ],
      ),
    );
  }

  Future<void> _abrirComprasSuministros() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SuministroBloc>(),
          child: RegistrarCompraPage(
            ciudadId: widget.ciudadId,
            ciudadNombre: widget.ciudadNombre,
          ),
        ),
      ),
    );
    if (mounted) {
      context.read<SuministroBloc>().add(
        ObtenerInventarioEvent(widget.ciudadId),
      );
    }
  }

  void _abrirComprasProductos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComprasProductoPage(
          ciudadIdInicial: widget.ciudadId,
          ciudadNombreInicial: widget.ciudadNombre,
        ),
      ),
    );
  }

  Future<void> _abrirTraslado() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TrasladoBloc>(),
          child: CrearTrasladoPage(
            ciudadOrigenId: widget.ciudadId,
            ciudadOrigenNombre: widget.ciudadNombre,
          ),
        ),
      ),
    );
    if (mounted) {
      context.read<SuministroBloc>().add(
        ObtenerInventarioEvent(widget.ciudadId),
      );
    }
  }

  void _mostrarAlertas(BuildContext context) {
    context.read<SuministroBloc>().add(ObtenerAlertasEvent(widget.ciudadId));
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<SuministroBloc>(),
        child: BlocBuilder<SuministroBloc, SuministroState>(
          builder: (context, state) {
            if (state is AlertasCargadas) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ Alertas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.stockBajo.isNotEmpty) ...[
                      const Text(
                        'Stock bajo:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      ...state.stockBajo.map(
                        (s) => ListTile(
                          leading: const Icon(
                            Icons.warning_outlined,
                            color: Colors.red,
                          ),
                          title: Text(s['nombre_suministro']),
                          subtitle: Text('Saldo: ${s['saldo']}'),
                        ),
                      ),
                    ],
                    if (state.proximosAVencer.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Próximos a vencer:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      ...state.proximosAVencer.map(
                        (s) => ListTile(
                          leading: const Icon(
                            Icons.schedule,
                            color: Colors.orange,
                          ),
                          title: Text(s['nombre_suministro']),
                          subtitle: Text(
                            'Vence en ${s['dias_restantes']} días',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          },
        ),
      ),
    ).whenComplete(() {
      if (context.mounted) {
        context.read<SuministroBloc>().add(
          ObtenerInventarioEvent(widget.ciudadId),
        );
      }
    });
  }
}

// ─── Tab Suministros (existente) ──────────────────────────────────────────────

class _TabSuministros extends StatelessWidget {
  final int ciudadId;
  const _TabSuministros({required this.ciudadId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuministroBloc, SuministroState>(
      builder: (context, state) {
        if (state is SuministroLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
          );
        }
        if (state is SuministroError) {
          return Center(child: Text(state.mensaje));
        }
        if (state is CompraRegistrada) {
          context.read<SuministroBloc>().add(ObtenerInventarioEvent(ciudadId));
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
          );
        }
        if (state is InventarioCargado) {
          return _buildLista(state.inventario, state.stockBajo);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildLista(
    List<InventarioItem> inventario,
    List<InventarioItem> stockBajo,
  ) {
    return Column(
      children: [
        if (stockBajo.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_outlined, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${stockBajo.length} suministro(s) con stock bajo',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: inventario.isEmpty
              ? const Center(
                  child: Text(
                    'No hay suministros en inventario',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: inventario.length,
                  itemBuilder: (_, i) => _ItemCard(item: inventario[i]),
                ),
        ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final InventarioItem item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.stockBajo ? Colors.red : const Color(0xFF8DC63F);
    final porcentaje = item.umbral > 0
        ? (item.saldo / item.umbral).clamp(0.0, 2.0)
        : 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.nombreSuministro,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (item.stockBajo)
                  const Icon(
                    Icons.warning_outlined,
                    color: Colors.red,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Text(
                  '${item.saldo} ${item.unidadMedida}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: porcentaje.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tipo: ${item.tipo}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Umbral: ${item.umbral}',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Productos ────────────────────────────────────────────────────────────

class _TabProductos extends StatefulWidget {
  final int ciudadId;
  const _TabProductos({required this.ciudadId});

  @override
  State<_TabProductos> createState() => _TabProductosState();
}

class _TabProductosState extends State<_TabProductos>
    with AutomaticKeepAliveClientMixin {
  late final PagoBloc _pagoBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pagoBloc = AppDependencies.createPagoBloc();
    _cargar();
  }

  @override
  void dispose() {
    _pagoBloc.close();
    super.dispose();
  }

  Future<void> _cargar() async {
    _pagoBloc.add(ListarInventarioProductosEvent(widget.ciudadId));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider.value(
      value: _pagoBloc,
      child: BlocBuilder<PagoBloc, PagoState>(
        builder: (context, state) {
          if (state is PagoLoading || state is PagoInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8DC63F)),
            );
          }

          if (state is PagoError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.mensaje,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _cargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is! InventarioProductosListado) {
            return const SizedBox();
          }

          final items = state.items;
          final stockBajoCount = items.where((i) => i.stockBajo).length;

          return RefreshIndicator(
            onRefresh: _cargar,
            child: Column(
              children: [
                if (stockBajoCount > 0)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_outlined,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$stockBajoCount producto(s) con stock bajo',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text(
                            'Sin productos en inventario',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: items.length,
                          itemBuilder: (_, i) =>
                              _ProductoItemCard(item: items[i]),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductoItemCard extends StatelessWidget {
  final ProductoInventarioItem item;
  const _ProductoItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.stockBajo ? Colors.orange : const Color(0xFF8DC63F);
    final porcentaje = item.umbral > 0
        ? (item.saldo / item.umbral).clamp(0.0, 2.0)
        : 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (item.stockBajo)
                  const Icon(
                    Icons.warning_outlined,
                    color: Colors.orange,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Text(
                  '${item.saldo} ${item.unidadMedida}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: porcentaje.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Compras: ${item.totalCompras}  â€¢  '
                  'Ventas: ${item.totalVentas}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Umbral: ${item.umbral}',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
