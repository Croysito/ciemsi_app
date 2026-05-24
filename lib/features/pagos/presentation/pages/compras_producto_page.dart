import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/app_dependencies.dart';
import '../../domain/entities/compra_producto.dart';
import '../../domain/entities/producto.dart';
import '../bloc/pago_bloc.dart';
import '../bloc/pago_event.dart';
import '../bloc/pago_state.dart';

class ComprasProductoPage extends StatefulWidget {
  final int? ciudadIdInicial;
  final String? ciudadNombreInicial;

  const ComprasProductoPage({
    super.key,
    this.ciudadIdInicial,
    this.ciudadNombreInicial,
  });

  @override
  State<ComprasProductoPage> createState() => _ComprasProductoPageState();
}

class _ComprasProductoPageState extends State<ComprasProductoPage> {
  late final PagoBloc _bloc;
  int? _ciudadId;
  String? _ciudadNombre;

  @override
  void initState() {
    super.initState();
    _ciudadId = widget.ciudadIdInicial;
    _ciudadNombre = widget.ciudadNombreInicial;
    _bloc = AppDependencies.createPagoBloc();
    if (_ciudadId != null) {
      _bloc.add(ListarComprasProductoEvent(ciudadId: _ciudadId));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _seleccionarCiudad(int id, String nombre) {
    setState(() {
      _ciudadId = id;
      _ciudadNombre = nombre;
    });
    _bloc.add(ListarComprasProductoEvent(ciudadId: id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: _ciudadId == null
          ? _SelectorCiudad(onSeleccionada: _seleccionarCiudad)
          : _ComprasView(
              ciudadId: _ciudadId!,
              ciudadNombre: _ciudadNombre ?? '',
            ),
    );
  }
}

// ─── Selector de ciudad (solo Doctora) ───────────────────────────────────────

class _SelectorCiudad extends StatefulWidget {
  final void Function(int, String) onSeleccionada;
  const _SelectorCiudad({required this.onSeleccionada});

  @override
  State<_SelectorCiudad> createState() => _SelectorCiudadState();
}

class _SelectorCiudadState extends State<_SelectorCiudad> {
  @override
  void initState() {
    super.initState();
    context.read<PagoBloc>().add(CargarCiudadesPagoEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Compras de Productos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8DC63F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<PagoBloc, PagoState>(
        buildWhen: (_, s) =>
            s is PagoLoading || s is CiudadesPagoCargadas || s is PagoError,
        builder: (context, state) {
          if (state is PagoLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8DC63F)),
            );
          }
          if (state is PagoError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.mensaje, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.read<PagoBloc>().add(CargarCiudadesPagoEvent()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final ciudades =
              state is CiudadesPagoCargadas ? state.ciudades : <Map<String, dynamic>>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Selecciona una ciudad',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ciudades.length,
                  itemBuilder: (_, i) {
                    final c = ciudades[i];
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
                          color: Color(0xFF8DC63F),
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
          );
        },
      ),
    );
  }
}

// ─── Vista principal de compras ───────────────────────────────────────────────

class _ComprasView extends StatelessWidget {
  final int ciudadId;
  final String ciudadNombre;

  const _ComprasView({required this.ciudadId, required this.ciudadNombre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compras de Productos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              ciudadNombre,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8DC63F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirRegistro(context),
        backgroundColor: const Color(0xFF8DC63F),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('Nueva compra', style: TextStyle(color: Colors.white)),
      ),
      body: BlocConsumer<PagoBloc, PagoState>(
        listener: (context, state) {
          if (state is CompraProductoRegistrada) {
            context.read<PagoBloc>().add(
              ListarComprasProductoEvent(ciudadId: ciudadId),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Compra registrada correctamente'),
                backgroundColor: Color(0xFF8DC63F),
              ),
            );
          } else if (state is PagoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PagoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ComprasProductoListadas) {
            final compras = state.compras;
            if (compras.isEmpty) {
              return const Center(
                child: Text(
                  'Sin compras registradas',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<PagoBloc>().add(
                ListarComprasProductoEvent(ciudadId: ciudadId),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: compras.length,
                itemBuilder: (_, i) => _CompraCard(compra: compras[i]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _abrirRegistro(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<PagoBloc>(),
        child: _RegistrarCompraForm(ciudadId: ciudadId),
      ),
    );
  }
}

// ─── Card de compra ───────────────────────────────────────────────────────────

class _CompraCard extends StatelessWidget {
  final CompraProducto compra;
  const _CompraCard({required this.compra});

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,##0.00', 'es');
    final dateFmt = DateFormat('dd/MM/yyyy', 'es');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF8DC63F),
          child: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
        ),
        title: Text(
          dateFmt.format(compra.fecha),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          compra.ciudad['nombreCiudad']?.toString() ?? '',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          'Bs. ${moneyFmt.format(compra.total)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8DC63F),
            fontSize: 13,
          ),
        ),
        children: [
          const Divider(height: 1),
          ...compra.items.map(
            (item) => ListTile(
              dense: true,
              title: Text(
                item.producto['nombre']?.toString() ?? '',
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: Text(
                '${item.cantidad} ${item.producto['unidadMedida'] ?? ''} × Bs. ${moneyFmt.format(item.precioUnitario)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              trailing: Text(
                'Bs. ${moneyFmt.format(item.subtotal)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Formulario registrar compra ─────────────────────────────────────────────

class _RegistrarCompraForm extends StatefulWidget {
  final int ciudadId;
  const _RegistrarCompraForm({required this.ciudadId});

  @override
  State<_RegistrarCompraForm> createState() => _RegistrarCompraFormState();
}

class _RegistrarCompraFormState extends State<_RegistrarCompraForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime _fecha = DateTime.now();
  final List<_ItemCompra> _items = [_ItemCompra()];
  List<Producto> _productos = [];
  bool _cargandoProductos = true;

  @override
  void initState() {
    super.initState();
    context.read<PagoBloc>().add(ListarProductosEvent());
  }

  @override
  void dispose() {
    for (final i in _items) {
      i.dispose();
    }
    super.dispose();
  }

  double get _total => _items.fold(0, (sum, item) {
        final cant = double.tryParse(item.cantidadCtrl.text) ?? 0;
        final precio = double.tryParse(item.precioCtrl.text) ?? 0;
        return sum + cant * precio;
      });

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,##0.00', 'es');
    final dateFmt = DateFormat('dd/MM/yyyy', 'es');

    return BlocListener<PagoBloc, PagoState>(
      listener: (context, state) {
        if (state is ProductosListados) {
          setState(() {
            _productos = state.productos.where((p) => p.estado).toList();
            _cargandoProductos = false;
          });
        } else if (state is CompraProductoRegistrada) {
          Navigator.pop(context);
        } else if (state is PagoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: _cargandoProductos
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      controller: scrollCtrl,
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 8,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Registrar Compra',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Fecha
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _fecha,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => _fecha = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Fecha',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18,
                                  ),
                                ),
                                child: Text(dateFmt.format(_fecha)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Productos',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),

                            ...List.generate(
                              _items.length,
                              (i) => StatefulBuilder(
                                key: ObjectKey(_items[i]),
                                builder: (ctx, setItem) => _buildItemRow(
                                  i,
                                  _items[i],
                                  moneyFmt,
                                  () => setItem(() {}),
                                ),
                              ),
                            ),

                            TextButton.icon(
                              onPressed: () =>
                                  setState(() => _items.add(_ItemCompra())),
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar producto'),
                            ),
                            const SizedBox(height: 8),

                            // Total
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                dense: true,
                                title: const Text(
                                  'Total compra',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: Text(
                                  'Bs. ${moneyFmt.format(_total)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF8DC63F),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            BlocBuilder<PagoBloc, PagoState>(
                              builder: (context, state) => SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      state is PagoLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8DC63F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: state is PagoLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Confirmar Compra',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(
    int index,
    _ItemCompra item,
    NumberFormat fmt,
    VoidCallback onUpdate,
  ) {
    final subtotal = (double.tryParse(item.cantidadCtrl.text) ?? 0) *
        (double.tryParse(item.precioCtrl.text) ?? 0);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Producto>(
                    initialValue: item.producto,
                    decoration: InputDecoration(
                      labelText: 'Producto',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _productos
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.nombre,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (p) {
                      item.producto = p;
                      if (p != null) {
                        item.precioCtrl.text =
                            p.precioVenta.toStringAsFixed(2);
                      }
                      onUpdate();
                      setState(() {});
                    },
                    validator: (_) =>
                        item.producto == null ? 'Requerido' : null,
                  ),
                ),
                if (_items.length > 1) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () =>
                        setState(() => _items.removeAt(index)),
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.cantidadCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (_) {
                      onUpdate();
                      setState(() {});
                    },
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if ((double.tryParse(v) ?? 0) <= 0) return 'Inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: item.precioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Precio unitario',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (_) {
                      onUpdate();
                      setState(() {});
                    },
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if ((double.tryParse(v) ?? 0) <= 0) return 'Inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Bs. ${fmt.format(subtotal)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_items.any((i) => i.producto == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione todos los productos')),
      );
      return;
    }

    context.read<PagoBloc>().add(RegistrarCompraProductoEvent(
          ciudadId: widget.ciudadId,
          fecha: DateFormat('yyyy-MM-dd').format(_fecha),
          items: _items
              .map((i) => {
                    'productoId': i.producto!.id,
                    'cantidad': double.parse(i.cantidadCtrl.text),
                    'precioUnitario': double.parse(i.precioCtrl.text),
                  })
              .toList(),
        ));
  }
}

class _ItemCompra {
  Producto? producto;
  final TextEditingController cantidadCtrl = TextEditingController(text: '1');
  final TextEditingController precioCtrl = TextEditingController();

  void dispose() {
    cantidadCtrl.dispose();
    precioCtrl.dispose();
  }
}
