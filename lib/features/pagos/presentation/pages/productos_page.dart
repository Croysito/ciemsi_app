import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/app_dependencies.dart';
import '../../domain/entities/producto.dart';
import '../bloc/pago_bloc.dart';
import '../bloc/pago_event.dart';
import '../bloc/pago_state.dart';

class ProductosPage extends StatelessWidget {
  const ProductosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppDependencies.createPagoBloc()..add(ListarProductosEvent()),
      child: const _ProductosView(),
    );
  }
}

class _ProductosView extends StatelessWidget {
  const _ProductosView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Productos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8DC63F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context),
        backgroundColor: const Color(0xFF8DC63F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<PagoBloc, PagoState>(
        listener: (context, state) {
          if (state is ProductoOperacionExitosa) {
            context.read<PagoBloc>().add(ListarProductosEvent());
          } else if (state is PagoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is PagoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductosListados) {
            final productos = state.productos;
            if (productos.isEmpty) {
              return const Center(
                child: Text('Sin productos registrados', style: TextStyle(color: Colors.grey)),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<PagoBloc>().add(ListarProductosEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: productos.length,
                itemBuilder: (_, i) => _ProductoCard(
                  producto: productos[i],
                  onEdit: () => _mostrarFormulario(context, producto: productos[i]),
                  onToggle: () => context.read<PagoBloc>().add(
                    CambiarEstadoProductoEvent(productos[i].id),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, {Producto? producto}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<PagoBloc>(),
        child: _ProductoForm(producto: producto),
      ),
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _ProductoCard({
    required this.producto,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'es');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: producto.estado
              ? const Color(0xFF8DC63F).withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.15),
          child: Icon(
            Icons.inventory_2_outlined,
            color: producto.estado ? const Color(0xFF8DC63F) : Colors.grey,
          ),
        ),
        title: Text(
          producto.nombre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: producto.estado ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bs. ${fmt.format(producto.precioVenta)}  •  ${producto.unidadMedida}',
              style: const TextStyle(fontSize: 12),
            ),
            if (producto.descripcion != null)
              Text(
                producto.descripcion!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              color: const Color(0xFF00B5C8),
            ),
            Switch(
              value: producto.estado,
              onChanged: (_) => onToggle(),
              activeThumbColor: const Color(0xFF8DC63F),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductoForm extends StatefulWidget {
  final Producto? producto;
  const _ProductoForm({this.producto});

  @override
  State<_ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<_ProductoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _unidadCtrl;
  late final TextEditingController _precioCtrl;
  late final TextEditingController _umbralCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreCtrl = TextEditingController(text: p?.nombre);
    _descripcionCtrl = TextEditingController(text: p?.descripcion);
    _unidadCtrl = TextEditingController(text: p?.unidadMedida ?? 'unidad');
    _precioCtrl = TextEditingController(
      text: p != null ? p.precioVenta.toStringAsFixed(2) : '',
    );
    _umbralCtrl = TextEditingController(text: p?.umbral.toString() ?? '0');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _unidadCtrl.dispose();
    _precioCtrl.dispose();
    _umbralCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.producto != null;
    return BlocListener<PagoBloc, PagoState>(
      listener: (context, state) {
        if (state is ProductoOperacionExitosa) Navigator.pop(context);
        if (state is PagoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esEdicion ? 'Editar Producto' : 'Nuevo Producto',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _field(_nombreCtrl, 'Nombre', required: true),
              const SizedBox(height: 12),
              _field(_descripcionCtrl, 'Descripción (opcional)'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field(_unidadCtrl, 'Unidad de medida', required: true)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _umbralCtrl, 'Umbral mínimo',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                _precioCtrl, 'Precio de venta (Bs.)',
                required: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),
              BlocBuilder<PagoBloc, PagoState>(
                builder: (context, state) => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state is PagoLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8DC63F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state is PagoLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            esEdicion ? 'Guardar cambios' : 'Crear producto',
                            style: const TextStyle(
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
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null
          : null,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final nombre = _nombreCtrl.text.trim();
    final descripcion = _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim();
    final unidad = _unidadCtrl.text.trim();
    final precio = double.tryParse(_precioCtrl.text) ?? 0;
    final umbral = int.tryParse(_umbralCtrl.text) ?? 0;

    if (widget.producto != null) {
      context.read<PagoBloc>().add(ModificarProductoEvent(
        id: widget.producto!.id,
        nombre: nombre,
        descripcion: descripcion,
        unidadMedida: unidad,
        precioVenta: precio,
        umbral: umbral,
        estado: widget.producto!.estado,
      ));
    } else {
      context.read<PagoBloc>().add(CrearProductoEvent(
        nombre: nombre,
        descripcion: descripcion,
        unidadMedida: unidad,
        precioVenta: precio,
        umbral: umbral,
      ));
    }
  }
}
