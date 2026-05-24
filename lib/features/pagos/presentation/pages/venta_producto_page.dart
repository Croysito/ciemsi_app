import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/producto.dart';
import '../bloc/pago_bloc.dart';
import '../bloc/pago_event.dart';
import '../bloc/pago_state.dart';

class VentaProductoPage extends StatefulWidget {
  final int pacienteId;
  final int ciudadId;

  const VentaProductoPage({
    super.key,
    required this.pacienteId,
    required this.ciudadId,
  });

  @override
  State<VentaProductoPage> createState() => _VentaProductoPageState();
}

class _VentaProductoPageState extends State<VentaProductoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notasCtrl = TextEditingController();
  String _metodo = 'efectivo';
  final List<_ItemVenta> _items = [_ItemVenta()];
  List<Producto> _productos = [];
  bool _cargandoProductos = true;

  @override
  void initState() {
    super.initState();
    context.read<PagoBloc>().add(ListarProductosEvent());
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _notasCtrl.dispose();
    super.dispose();
  }

  double get _total => _items.fold(0, (sum, item) {
        final cant = double.tryParse(item.cantidadCtrl.text) ?? 0;
        final precio = item.producto?.precioVenta ?? 0;
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
          });
        } else if (state is IngresoRegistrado) {
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
          title: const Text(
            'Venta de Producto',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

                      // Método de pago
                      const Text('Método de pago',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      RadioGroup<String>(
                        groupValue: _metodo,
                        onChanged: (v) => setState(() => _metodo = v!),
                        child: Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                value: 'efectivo',
                                title: const Text('Efectivo'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                value: 'qr',
                                title: const Text('QR'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
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
                                : const Text(
                                    'Confirmar Venta',
                                    style: TextStyle(
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
        (item.producto?.precioVenta ?? 0);
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
    final items = _items.map((item) => {
          'productoId': item.producto!.id,
          'cantidad': double.parse(item.cantidadCtrl.text),
          'precioUnitario': item.producto!.precioVenta,
        }).toList();

    context.read<PagoBloc>().add(RegistrarVentaProductoEvent(
          pacienteId: widget.pacienteId,
          ciudadId: widget.ciudadId,
          items: items,
          metodo: _metodo,
          notas: _notasCtrl.text.isEmpty ? null : _notasCtrl.text,
        ));
  }
}

class _ItemVenta {
  Producto? producto;
  final TextEditingController cantidadCtrl = TextEditingController(text: '1');

  void dispose() => cantidadCtrl.dispose();
}
