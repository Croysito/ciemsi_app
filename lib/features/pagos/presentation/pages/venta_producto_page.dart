import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/producto.dart';
import '../../domain/entities/ingreso.dart';
import '../bloc/pago_bloc.dart';
import '../bloc/pago_event.dart';
import '../bloc/pago_state.dart';
import '../widgets/monto_mixto_field.dart';

class VentaProductoPage extends StatefulWidget {
  final int pacienteId;
  final int ciudadId;
  /// Si se provee, la página edita esta venta ya registrada en vez de crear una nueva.
  final Ingreso? ingresoAEditar;

  const VentaProductoPage({
    super.key,
    required this.pacienteId,
    required this.ciudadId,
    this.ingresoAEditar,
  });

  bool get esEdicion => ingresoAEditar != null;

  @override
  State<VentaProductoPage> createState() => _VentaProductoPageState();
}

class _VentaProductoPageState extends State<VentaProductoPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _notasCtrl;
  late final MontoMixtoController _montoMixtoCtrl;
  late final List<_ItemVenta> _items;
  List<Producto> _productos = [];
  bool _cargandoProductos = true;

  @override
  void initState() {
    super.initState();
    final editando = widget.ingresoAEditar;
    _notasCtrl = TextEditingController(text: editando?.notas ?? '');
    _montoMixtoCtrl = MontoMixtoController(
      efectivoInicial: editando?.montoEfectivo ?? 0,
      qrInicial: editando?.montoQr ?? 0,
    );
    _items = editando != null && editando.items.isNotEmpty
        ? editando.items
            .map((i) => _ItemVenta(
                  productoId: i.producto['id'] as int,
                  productoNombre: i.producto['nombre'] as String? ?? '',
                  precioVenta: i.precioUnitario,
                  cantidadInicial: i.cantidad,
                ))
            .toList()
        : [_ItemVenta()];
    context.read<PagoBloc>().add(ListarProductosEvent());
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _notasCtrl.dispose();
    _montoMixtoCtrl.dispose();
    super.dispose();
  }

  double get _total => _items.fold(0, (sum, item) {
        final cant = double.tryParse(item.cantidadCtrl.text) ?? 0;
        final precio = item.producto?.precioVenta ?? item.precioVenta ?? 0;
        return sum + cant * precio;
      });

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,##0.00', 'es');

    return BlocListener<PagoBloc, PagoState>(
      listener: (context, state) {
        if (state is ProductosListados) {
          setState(() {
            _productos = state.productos;
            _cargandoProductos = false;
            // Empareja los productos precargados (modo edición) con la lista real
            for (final item in _items) {
              if (item.producto == null && item.productoId != null) {
                final match = _productos.where((p) => p.id == item.productoId);
                if (match.isNotEmpty) item.producto = match.first;
              }
            }
          });
        } else if (state is IngresoRegistrado || state is IngresoActualizado) {
          Navigator.pop(context, true);
        } else if (state is PagoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: Text(
            widget.esEdicion ? 'Editar Venta' : 'Venta de Producto',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF8DC63F),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _cargandoProductos
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Items
                      ...List.generate(_items.length, (i) {
                        return StatefulBuilder(
                          key: ObjectKey(_items[i]),
                          builder: (ctx, setItemState) => _buildItemCard(
                            i, _items[i],
                            moneyFmt,
                            () => setItemState(() {}),
                          ),
                        );
                      }),

                      // Agregar ítem
                      TextButton.icon(
                        onPressed: () => setState(() => _items.add(_ItemVenta())),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar producto'),
                      ),
                      const SizedBox(height: 16),

                      // Total
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: const Text('Total a cobrar',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Text(
                            'Bs. ${moneyFmt.format(_total)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF8DC63F),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Método de pago (efectivo + QR)
                      MontoMixtoField(
                        controller: _montoMixtoCtrl,
                        total: _total,
                      ),
                      const SizedBox(height: 12),

                      // Notas
                      TextFormField(
                        controller: _notasCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Notas (opcional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 28),

                      BlocBuilder<PagoBloc, PagoState>(
                        builder: (context, state) => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state is PagoLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8DC63F),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: state is PagoLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    widget.esEdicion ? 'Guardar Cambios' : 'Confirmar Venta',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildItemCard(int index, _ItemVenta item, NumberFormat fmt, VoidCallback onUpdate) {
    final subtotal = (double.tryParse(item.cantidadCtrl.text) ?? 0) *
        (item.producto?.precioVenta ?? item.precioVenta ?? 0);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Producto>(
                    initialValue: item.producto,
                    decoration: InputDecoration(
                      labelText: 'Producto',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _productos
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text('${p.nombre} (Bs. ${fmt.format(p.precioVenta)})',
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (p) {
                      item.producto = p;
                      onUpdate();
                      setState(() {});
                    },
                    validator: (_) =>
                        item.producto == null ? 'Seleccione un producto' : null,
                  ),
                ),
                if (_items.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _items.removeAt(index)),
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                const SizedBox(width: 12),
                Text(
                  'Bs. ${fmt.format(subtotal)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
    if (_items.any((item) => item.producto == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione todos los productos')),
      );
      return;
    }

    final diferencia = (_total - _montoMixtoCtrl.total).abs();
    if (diferencia > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El efectivo + QR debe sumar el total de la venta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final items = _items.map((item) => {
          'productoId': item.producto!.id,
          'cantidad': double.parse(item.cantidadCtrl.text),
          'precioUnitario': item.producto!.precioVenta,
        }).toList();

    if (widget.esEdicion) {
      context.read<PagoBloc>().add(EditarVentaProductoEvent(
            id: widget.ingresoAEditar!.id,
            items: items,
            montoEfectivo: _montoMixtoCtrl.efectivo,
            montoQr: _montoMixtoCtrl.qr,
            notas: _notasCtrl.text.isEmpty ? null : _notasCtrl.text,
          ));
    } else {
      context.read<PagoBloc>().add(RegistrarVentaProductoEvent(
            pacienteId: widget.pacienteId,
            ciudadId: widget.ciudadId,
            items: items,
            montoEfectivo: _montoMixtoCtrl.efectivo,
            montoQr: _montoMixtoCtrl.qr,
            notas: _notasCtrl.text.isEmpty ? null : _notasCtrl.text,
          ));
    }
  }
}

class _ItemVenta {
  Producto? producto;
  final int? productoId;
  final String? productoNombre;
  final double? precioVenta;
  final TextEditingController cantidadCtrl;

  _ItemVenta({
    this.productoId,
    this.productoNombre,
    this.precioVenta,
    double cantidadInicial = 1,
  }) : cantidadCtrl = TextEditingController(
          text: cantidadInicial == cantidadInicial.roundToDouble()
              ? cantidadInicial.toStringAsFixed(0)
              : cantidadInicial.toString(),
        );

  void dispose() => cantidadCtrl.dispose();
}
