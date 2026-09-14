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
import 'package:ciemsi_app/features/suministros/domain/entities/ciudad_inventario.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/inventario_comparado.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/inventario_item.dart';
import 'package:ciemsi_app/features/pagos/presentation/pages/compras_producto_page.dart';
import 'package:ciemsi_app/features/traslados/presentation/bloc/traslado_bloc.dart';
import 'package:ciemsi_app/features/traslados/presentation/bloc/traslado_event.dart';
import 'package:ciemsi_app/features/traslados/presentation/bloc/traslado_state.dart';
import 'package:ciemsi_app/features/traslados/presentation/pages/crear_traslado_page.dart';
import '../widgets/inventario_comparado_skeleton.dart';
import '../widgets/inventario_comparado_table.dart';
import 'registrar_compra_page.dart';

enum _ModoInventario { miCiudad, comparar }

/// Qué operación de `TrasladoBloc` está en vuelo en el panel inline, para
/// que el mismo `TrasladoOperacionExitosa`/`TrasladoError` genérico del
/// bloc se interprete distinto según si fue crear o deshacer.
enum _AccionTraslado { ninguna, creando, deshaciendo }

/// P4 · Inventario comparado — reemplaza el `TabController` de 2 tabs
/// (Suministros/Productos como única navegación) por un segmentado de dos
/// **modos**: "Mi ciudad" (la vista de siempre, ahora con selector propio
/// de ciudad) y "Comparar" (las tres ciudades a la vez, con traslado desde
/// la fila). Comparar sólo lo ven Doctora, Admin, o un Asistente con
/// `veTodasCiudades`.
class InventarioPage extends StatefulWidget {
  final int? ciudadId;
  final String? ciudadNombre;
  final VoidCallback? onMenuTap;
  final Usuario usuario;
  final void Function(int, String)? onCiudadSeleccionada;

  const InventarioPage({
    super.key,
    required this.ciudadId,
    required this.ciudadNombre,
    this.onMenuTap,
    required this.usuario,
    this.onCiudadSeleccionada,
  });

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late _ModoInventario _modo;
  int? _miCiudadId;
  String? _miCiudadNombre;
  bool _buscando = false;
  final _busquedaController = TextEditingController();

  bool get _puedeComparar =>
      widget.usuario.rol == 'Doctora' || widget.usuario.rol == 'Admin' || widget.usuario.veTodasCiudades;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _miCiudadId = widget.ciudadId;
    _miCiudadNombre = widget.ciudadNombre;
    _modo = _puedeComparar ? _ModoInventario.comparar : _ModoInventario.miCiudad;
    if (_puedeComparar) {
      context.read<SuministroBloc>().add(ObtenerInventarioComparadoEvent());
    }
    if (_miCiudadId != null) {
      context.read<SuministroBloc>().add(ObtenerInventarioEvent(_miCiudadId!));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  void _elegirCiudadMiCiudad(CiudadInventario ciudad) {
    setState(() {
      _miCiudadId = ciudad.id;
      _miCiudadNombre = ciudad.nombre;
    });
    widget.onCiudadSeleccionada?.call(ciudad.id, ciudad.nombre);
    context.read<SuministroBloc>().add(ObtenerInventarioEvent(ciudad.id));
  }

  String get _subtitulo {
    if (_modo == _ModoInventario.comparar) return 'Suministros · las tres ciudades';
    return _miCiudadNombre != null ? 'Suministros · $_miCiudadNombre' : 'Suministros';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: _buildAppBar(),
      floatingActionButton: _buildFab(),
      body: Column(
        children: [
          if (_puedeComparar) _segmentado(),
          if (_buscando && _modo == _ModoInventario.comparar) _campoBusqueda(),
          Expanded(
            child: _modo == _ModoInventario.comparar
                ? _ComparadoView(usuario: widget.usuario, filtro: _busquedaController.text)
                : _miCiudadContenido(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        toolbarHeight: 64,
        leading: widget.onMenuTap != null
            ? IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: widget.onMenuTap)
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Inventario', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(
              _subtitulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xBFFFFFFF)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: _modo == _ModoInventario.comparar
            ? [
                IconButton(
                  icon: Icon(_buscando ? Icons.close : Icons.search, color: Colors.white),
                  onPressed: () => setState(() {
                    _buscando = !_buscando;
                    if (!_buscando) _busquedaController.clear();
                  }),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _miCiudadId == null
                      ? null
                      : () => context.read<SuministroBloc>().add(ObtenerInventarioEvent(_miCiudadId!)),
                ),
                IconButton(icon: const Icon(Icons.warning_outlined), onPressed: () => _mostrarAlertas(context)),
              ],
      ),
    );
  }

  Widget _segmentado() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: const Color(0xFFE4E6E8), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(child: _segmento('Mi ciudad', _ModoInventario.miCiudad)),
            Expanded(child: _segmento('Comparar', _ModoInventario.comparar)),
          ],
        ),
      ),
    );
  }

  Widget _segmento(String texto, _ModoInventario valor) {
    final activo = _modo == valor;
    return GestureDetector(
      onTap: () => setState(() => _modo = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: activo ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: activo ? const [BoxShadow(color: Color(0x1F000000), blurRadius: 2, offset: Offset(0, 1))] : null,
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 13,
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            color: activo ? const Color(0xFF16191C) : const Color(0xFF6B7075),
          ),
        ),
      ),
    );
  }

  Widget _campoBusqueda() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: TextField(
        controller: _busquedaController,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Buscar suministro',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _miCiudadContenido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_puedeComparar) _selectorCiudad(),
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00B5C8),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00B5C8),
          tabs: const [
            Tab(icon: Icon(Icons.medication_outlined), text: 'Suministros'),
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Productos'),
          ],
        ),
        Expanded(
          child: _miCiudadId == null
              ? const Center(child: Text('Selecciona una ciudad', style: TextStyle(color: Colors.grey)))
              : TabBarView(
                  key: ValueKey('mi_ciudad_$_miCiudadId'),
                  controller: _tabController,
                  children: [
                    _TabSuministros(ciudadId: _miCiudadId!),
                    _TabProductos(ciudadId: _miCiudadId!),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _selectorCiudad() {
    return BlocBuilder<SuministroBloc, SuministroState>(
      buildWhen: (_, state) => state is InventarioComparadoCargado,
      builder: (context, state) {
        final ciudades = state is InventarioComparadoCargado ? state.datos.ciudades : const <CiudadInventario>[];
        if (ciudades.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF757575)),
              const SizedBox(width: 6),
              DropdownButton<int>(
                value: _miCiudadId,
                underline: const SizedBox.shrink(),
                items: ciudades
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (id) {
                  if (id == null) return;
                  _elegirCiudadMiCiudad(ciudades.firstWhere((c) => c.id == id));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _buildFab() {
    if (_modo == _ModoInventario.comparar) {
      return FloatingActionButton.extended(
        heroTag: 'fab_compra_comparado',
        backgroundColor: const Color(0xFF8DC63F),
        onPressed: _abrirComprasDesdeComparado,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('Registrar compra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      );
    }
    if (_miCiudadId == null) return null;
    return AnimatedBuilder(
      animation: _tabController,
      builder: (_, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'fab_compra',
            backgroundColor: const Color(0xFF8DC63F),
            onPressed: _tabController.index == 0 ? _abrirComprasSuministros : _abrirComprasProductos,
            child: const Icon(Icons.add_shopping_cart, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'fab_traslado',
            backgroundColor: const Color(0xFF00B5C8),
            onPressed: _abrirTraslado,
            child: const Icon(Icons.swap_horiz, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirComprasDesdeComparado() async {
    final state = context.read<SuministroBloc>().state;
    final ciudades = state is InventarioComparadoCargado ? state.datos.ciudades : const <CiudadInventario>[];
    if (ciudades.isEmpty) return;
    final ciudad = await showModalBottomSheet<CiudadInventario>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('¿En qué ciudad?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            for (final c in ciudades)
              ListTile(
                leading: Container(width: 10, height: 10, decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
                title: Text(c.nombre),
                onTap: () => Navigator.pop(sheetContext, c),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (ciudad == null || !mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SuministroBloc>(),
          child: RegistrarCompraPage(ciudadId: ciudad.id, ciudadNombre: ciudad.nombre),
        ),
      ),
    );
    if (mounted) context.read<SuministroBloc>().add(ObtenerInventarioComparadoEvent());
  }

  Future<void> _abrirComprasSuministros() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SuministroBloc>(),
          child: RegistrarCompraPage(ciudadId: _miCiudadId!, ciudadNombre: _miCiudadNombre ?? ''),
        ),
      ),
    );
    if (mounted) context.read<SuministroBloc>().add(ObtenerInventarioEvent(_miCiudadId!));
  }

  void _abrirComprasProductos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComprasProductoPage(ciudadIdInicial: _miCiudadId!, ciudadNombreInicial: _miCiudadNombre ?? ''),
      ),
    );
  }

  Future<void> _abrirTraslado() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TrasladoBloc>(),
          child: CrearTrasladoPage(ciudadOrigenId: _miCiudadId!, ciudadOrigenNombre: _miCiudadNombre ?? ''),
        ),
      ),
    );
    if (mounted) context.read<SuministroBloc>().add(ObtenerInventarioEvent(_miCiudadId!));
  }

  void _mostrarAlertas(BuildContext context) {
    if (_miCiudadId == null) return;
    context.read<SuministroBloc>().add(ObtenerAlertasEvent(_miCiudadId!));
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                    const Text('⚠️ Alertas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (state.stockBajo.isNotEmpty) ...[
                      const Text('Stock bajo:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ...state.stockBajo.map(
                        (s) => ListTile(
                          leading: const Icon(Icons.warning_outlined, color: Colors.red),
                          title: Text(s['nombre_suministro']),
                          subtitle: Text('Saldo: ${s['saldo']}'),
                        ),
                      ),
                    ],
                    if (state.proximosAVencer.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Próximos a vencer:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                      ...state.proximosAVencer.map(
                        (s) => ListTile(
                          leading: const Icon(Icons.schedule, color: Colors.orange),
                          title: Text(s['nombre_suministro']),
                          subtitle: Text('Vence en ${s['dias_restantes']} días'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00B5C8)));
          },
        ),
      ),
    ).whenComplete(() {
      if (context.mounted && _miCiudadId != null) {
        context.read<SuministroBloc>().add(ObtenerInventarioEvent(_miCiudadId!));
      }
    });
  }
}

// ─── Modo Comparar ─────────────────────────────────────────────────────────

/// Matriz de las tres ciudades a la vez, con el traslado inline. El estado
/// de fila abierta y el parche optimista de saldos viven acá, no en el
/// bloc (P4 · "Presentación en Flutter").
class _ComparadoView extends StatefulWidget {
  final Usuario usuario;
  final String filtro;
  const _ComparadoView({required this.usuario, required this.filtro});

  @override
  State<_ComparadoView> createState() => _ComparadoViewState();
}

class _ComparadoViewState extends State<_ComparadoView> {
  int? _filaAbiertaId;
  int? _ciudadOrigenId;
  String? _errorPanel;

  /// Saldo optimista (id de suministro → id de ciudad → saldo) que
  /// sobrescribe lo que devuelve el bloc mientras un traslado recién
  /// creado no se confirma o se deshace desde afuera.
  final Map<int, Map<int, double>> _parche = {};

  _AccionTraslado _accion = _AccionTraslado.ninguna;
  int? _trasladoPendienteId;
  int? _itemTrasladoPendiente;
  int? _ciudadOrigenPendiente;

  void _tocarCelda(ItemComparado item, CiudadInventario ciudad) {
    setState(() {
      _errorPanel = null;
      if (_filaAbiertaId == item.id && _ciudadOrigenId == ciudad.id) {
        _filaAbiertaId = null;
        _ciudadOrigenId = null;
      } else {
        _filaAbiertaId = item.id;
        _ciudadOrigenId = ciudad.id;
      }
    });
  }

  void _tocarSwap(ItemComparado item, List<CiudadInventario> ciudades) {
    if (_filaAbiertaId == item.id) {
      setState(() {
        _filaAbiertaId = null;
        _ciudadOrigenId = null;
        _errorPanel = null;
      });
      return;
    }
    // Origen precargado con la ciudad de mayor saldo.
    final mayor = ciudades.reduce((a, b) => item.saldoEn(a.id) >= item.saldoEn(b.id) ? a : b);
    setState(() {
      _filaAbiertaId = item.id;
      _ciudadOrigenId = mayor.id;
      _errorPanel = null;
    });
  }

  void _cerrarPanel() {
    setState(() {
      _filaAbiertaId = null;
      _ciudadOrigenId = null;
      _errorPanel = null;
    });
  }

  void _crearTraslado(ItemComparado item, int cantidad, int destinoId) {
    final origenId = _ciudadOrigenId!;
    setState(() {
      final saldos = _parche.putIfAbsent(item.id, () => {});
      saldos[origenId] = item.saldoEn(origenId) - cantidad;
      saldos[destinoId] = item.saldoEn(destinoId) + cantidad;
      _accion = _AccionTraslado.creando;
      _itemTrasladoPendiente = item.id;
      _ciudadOrigenPendiente = origenId;
      _filaAbiertaId = null;
      _ciudadOrigenId = null;
      _errorPanel = null;
    });
    context.read<TrasladoBloc>().add(CrearTrasladoEvent(
          tipo: 'SUMINISTRO',
          suministroId: item.id,
          ciudadOrigenId: origenId,
          ciudadDestinoId: destinoId,
          cantidad: cantidad.toDouble(),
        ));
  }

  void _deshacer() {
    final id = _trasladoPendienteId;
    final ciudadId = _ciudadOrigenPendiente;
    if (id == null || ciudadId == null) return;
    _accion = _AccionTraslado.deshaciendo;
    context.read<TrasladoBloc>().add(DevolverTrasladoEvent(id, ciudadId));
  }

  void _revertirParche(int? itemId) {
    if (itemId == null) return;
    setState(() => _revertirParcheSinBuild(itemId));
  }

  void _revertirParcheSinBuild(int? itemId) {
    if (itemId == null) return;
    _parche.remove(itemId);
  }

  InventarioComparado _aplicarParche(InventarioComparado datos) {
    if (_parche.isEmpty) return datos;
    final items = datos.items.map((item) {
      final overrides = _parche[item.id];
      if (overrides == null) return item;
      final saldos = item.saldos
          .map((s) => overrides.containsKey(s.ciudadId) ? SaldoCiudad(ciudadId: s.ciudadId, saldo: overrides[s.ciudadId]!) : s)
          .toList();
      for (final entry in overrides.entries) {
        if (!saldos.any((s) => s.ciudadId == entry.key)) {
          saldos.add(SaldoCiudad(ciudadId: entry.key, saldo: entry.value));
        }
      }
      return ItemComparado(
        id: item.id,
        nombreSuministro: item.nombreSuministro,
        unidadMedida: item.unidadMedida,
        tipo: item.tipo,
        umbral: item.umbral,
        saldos: saldos,
      );
    }).toList();
    return InventarioComparado(ciudades: datos.ciudades, items: items);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrasladoBloc, TrasladoState>(
      listener: (context, state) {
        if (state is TrasladoOperacionExitosa && _accion == _AccionTraslado.creando) {
          _accion = _AccionTraslado.ninguna;
          _trasladoPendienteId = state.trasladoId;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: const Text('Traslado creado · pendiente de confirmación'),
              action: SnackBarAction(label: 'Deshacer', onPressed: _deshacer),
              duration: const Duration(seconds: 6),
            ));
        } else if (state is TrasladoOperacionExitosa && _accion == _AccionTraslado.deshaciendo) {
          // El "Deshacer" (devolver) se confirmó: el parche ya cumplió su
          // función, el próximo refresco trae el saldo real del backend.
          _accion = _AccionTraslado.ninguna;
          _revertirParche(_itemTrasladoPendiente);
          _trasladoPendienteId = null;
          _ciudadOrigenPendiente = null;
          _itemTrasladoPendiente = null;
          context.read<SuministroBloc>().add(ObtenerInventarioComparadoEvent());
        } else if (state is TrasladoError && _accion == _AccionTraslado.creando) {
          // "Si la llamada falla, los saldos vuelven y el panel se reabre
          // con el error dentro, no en snackbar."
          _accion = _AccionTraslado.ninguna;
          setState(() {
            _revertirParcheSinBuild(_itemTrasladoPendiente);
            _filaAbiertaId = _itemTrasladoPendiente;
            _ciudadOrigenId = _ciudadOrigenPendiente;
            _errorPanel = state.mensaje;
          });
        } else if (state is TrasladoError && _accion == _AccionTraslado.deshaciendo) {
          // El traslado sigue como estaba (no se pudo devolver) — el
          // parche se queda, es lo que refleja la realidad ahora mismo.
          _accion = _AccionTraslado.ninguna;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('No se pudo deshacer: ${state.mensaje}')));
        }
      },
      child: BlocBuilder<SuministroBloc, SuministroState>(
        builder: (context, state) {
          if (state is SuministroLoading) {
            return const Padding(padding: EdgeInsets.all(16), child: InventarioComparadoSkeleton());
          }
          if (state is SuministroError) {
            return _estadoError(context, state.mensaje);
          }
          if (state is! InventarioComparadoCargado) {
            return const Padding(padding: EdgeInsets.all(16), child: InventarioComparadoSkeleton());
          }

          final datos = _aplicarParche(state.datos);
          if (datos.items.isEmpty) {
            return _estadoSinDatos(context);
          }

          final filtrados = widget.filtro.trim().isEmpty
              ? datos.items
              : datos.items
                  .where((i) => i.nombreSuministro.toLowerCase().contains(widget.filtro.trim().toLowerCase()))
                  .toList();

          return RefreshIndicator(
            onRefresh: () async => context.read<SuministroBloc>().add(ObtenerInventarioComparadoEvent()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                InventarioComparadoTable(
                  datos: InventarioComparado(ciudades: datos.ciudades, items: filtrados),
                  filaAbiertaId: _filaAbiertaId,
                  ciudadOrigenId: _ciudadOrigenId,
                  ciudadUsuarioId: widget.usuario.ciudad?.id,
                  errorPanel: _errorPanel,
                  onTocarCelda: _tocarCelda,
                  onTocarSwap: (item) => _tocarSwap(item, datos.ciudades),
                  onCerrarPanel: _cerrarPanel,
                  onCrearTraslado: _crearTraslado,
                ),
                const SizedBox(height: 12),
                _leyenda(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _leyenda() {
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: const [
        Text('Rojo: bajo el umbral', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
        Text('Ámbar: al filo', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
        Text('Gris: en cero, sin alerta', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
      ],
    );
  }

  Widget _estadoError(BuildContext context, String mensaje) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.read<SuministroBloc>().add(ObtenerInventarioComparadoEvent()),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _estadoSinDatos(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Todavía no hay suministros cargados', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Suministros (existente, sin cambios de contenido) ────────────────

class _TabSuministros extends StatelessWidget {
  final int ciudadId;
  const _TabSuministros({required this.ciudadId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuministroBloc, SuministroState>(
      builder: (context, state) {
        if (state is SuministroLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00B5C8)));
        }
        if (state is SuministroError) {
          return Center(child: Text(state.mensaje));
        }
        if (state is CompraRegistrada) {
          context.read<SuministroBloc>().add(ObtenerInventarioEvent(ciudadId));
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00B5C8)));
        }
        if (state is InventarioCargado) {
          return _buildLista(state.inventario, state.stockBajo);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildLista(List<InventarioItem> inventario, List<InventarioItem> stockBajo) {
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
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: inventario.isEmpty
              ? const Center(child: Text('No hay suministros en inventario', style: TextStyle(color: Colors.grey)))
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
    final porcentaje = item.umbral > 0 ? (item.saldo / item.umbral).clamp(0.0, 2.0) : 1.0;

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
                Expanded(child: Text(item.nombreSuministro, style: const TextStyle(fontWeight: FontWeight.bold))),
                if (item.stockBajo) const Icon(Icons.warning_outlined, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${item.saldo} ${item.unidadMedida}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
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
                Text('Tipo: ${item.tipo}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Umbral: ${item.umbral}', style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Productos (existente, sin cambios de contenido) ──────────────────

class _TabProductos extends StatefulWidget {
  final int ciudadId;
  const _TabProductos({required this.ciudadId});

  @override
  State<_TabProductos> createState() => _TabProductosState();
}

class _TabProductosState extends State<_TabProductos> with AutomaticKeepAliveClientMixin {
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
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8DC63F)));
          }

          if (state is PagoError) {
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
                        const Icon(Icons.warning_outlined, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$stockBajoCount producto(s) con stock bajo',
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('Sin productos en inventario', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: items.length,
                          itemBuilder: (_, i) => _ProductoItemCard(item: items[i]),
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
    final porcentaje = item.umbral > 0 ? (item.saldo / item.umbral).clamp(0.0, 2.0) : 1.0;

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
                Expanded(child: Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold))),
                if (item.stockBajo) const Icon(Icons.warning_outlined, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${item.saldo} ${item.unidadMedida}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
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
                  'Compras: ${item.totalCompras}  •  Ventas: ${item.totalVentas}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text('Umbral: ${item.umbral}', style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
