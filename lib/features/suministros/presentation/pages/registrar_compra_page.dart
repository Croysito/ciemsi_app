import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_event.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_state.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/suministro.dart';

class RegistrarCompraPage extends StatefulWidget {
  final int ciudadId;
  final String ciudadNombre;

  const RegistrarCompraPage({
    super.key,
    required this.ciudadId,
    required this.ciudadNombre,
  });

  @override
  State<RegistrarCompraPage> createState() => _RegistrarCompraPageState();
}

class _RegistrarCompraPageState extends State<RegistrarCompraPage> {
  List<Suministro> _suministros = [];
  final List<Map<String, dynamic>> _items = [];
  DateTime? _fecha;

  @override
  void initState() {
    super.initState();
    context.read<SuministroBloc>().add(CargarSuministrosCatalogoEvent());
  }

  void _agregarItem() {
    showDialog(
      context: context,
      builder: (_) => _DialogAgregarItem(
        suministros: _suministros,
        onAgregar: (item) {
          setState(() => _items.add(item));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          'Compra - ${widget.ciudadNombre}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<SuministroBloc, SuministroState>(
        listener: (context, state) {
          if (state is CatalogoCargado) {
            setState(() => _suministros = state.suministros);
          }
          if (state is CompraRegistrada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Compra registrada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is SuministroError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha
                    GestureDetector(
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          locale: const Locale('es', 'ES'),
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF00B5C8),
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (fecha != null) {
                          setState(() => _fecha = fecha);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF00B5C8),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _fecha != null
                                  ? DateFormat('dd/MM/yyyy').format(_fecha!)
                                  : 'Fecha de compra (hoy por defecto)',
                              style: TextStyle(
                                color:
                                    _fecha != null ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items de compra',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00B5C8),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _agregarItem,
                          icon: const Icon(Icons.add, color: Color(0xFF8DC63F)),
                          label: const Text(
                            'Agregar',
                            style: TextStyle(color: Color(0xFF8DC63F)),
                          ),
                        ),
                      ],
                    ),
                    if (_items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No hay items agregados',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._items.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        final esMedicamento =
                            item['tipo'] == TipoSuministro.MEDICAMENTO.name;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              esMedicamento
                                  ? Icons.medication_outlined
                                  : Icons.inventory_2_outlined,
                              color: const Color(0xFF00B5C8),
                            ),
                            title: Text(
                              item['nombreSuministro'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cant: ${item['cantidad']} • Compra: Bs ${item['precioUnitario']} c/u'
                                  '${item['fechaVencimiento'] != null ? ' • Vence: ${item['fechaVencimiento']}' : ''}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (esMedicamento &&
                                    item['precioVentaBase'] != null)
                                  Text(
                                    'Precio venta base: Bs ${item['precioVentaBase']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8DC63F),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            isThreeLine: esMedicamento &&
                                item['precioVentaBase'] != null,
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  setState(() => _items.removeAt(i)),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            // Botón guardar
            Padding(
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<SuministroBloc, SuministroState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is SuministroLoading || _items.isEmpty
                          ? null
                          : () {
                              final items = _items.map((item) {
                                final map = <String, dynamic>{
                                  'suministroId': item['suministroId'],
                                  'cantidad': item['cantidad'],
                                  'precioUnitario': item['precioUnitario'],
                                };
                                if (item['fechaVencimiento'] != null) {
                                  map['fechaVencimiento'] =
                                      item['fechaVencimiento'];
                                }
                                if (item['precioVentaBase'] != null) {
                                  map['precioVentaBase'] =
                                      item['precioVentaBase'];
                                }
                                return map;
                              }).toList();
                              context.read<SuministroBloc>().add(
                                RegistrarCompraEvent(
                                  ciudadId: widget.ciudadId,
                                  items: items,
                                  fecha: _fecha != null
                                      ? DateFormat('yyyy-MM-dd').format(_fecha!)
                                      : null,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DC63F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state is SuministroLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Registrar Compra',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

class _DialogAgregarItem extends StatefulWidget {
  final List<Suministro> suministros;
  final Function(Map<String, dynamic>) onAgregar;

  const _DialogAgregarItem({
    required this.suministros,
    required this.onAgregar,
  });

  @override
  State<_DialogAgregarItem> createState() => _DialogAgregarItemState();
}

class _DialogAgregarItemState extends State<_DialogAgregarItem> {
  Suministro? _suministroSeleccionado;
  final _cantidadController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaBaseController = TextEditingController();
  DateTime? _fechaVencimiento;

  bool get _esMedicamento =>
      _suministroSeleccionado?.tipo == TipoSuministro.MEDICAMENTO;

  @override
  void dispose() {
    _cantidadController.dispose();
    _precioCompraController.dispose();
    _precioVentaBaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Suministro>(
              hint: const Text('Seleccionar suministro'),
              initialValue: _suministroSeleccionado,
              items: widget.suministros
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.nombreSuministro),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                _suministroSeleccionado = v;
                _precioVentaBaseController.clear();
              }),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _precioCompraController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Precio de compra (Bs)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_esMedicamento) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _precioVentaBaseController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Precio de venta base (Bs) *',
                  labelStyle: const TextStyle(color: Color(0xFF8DC63F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8DC63F)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF8DC63F),
                      width: 2,
                    ),
                  ),
                  helperText: 'Requerido para medicamentos',
                  helperStyle: const TextStyle(color: Color(0xFF8DC63F)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  locale: const Locale('es', 'ES'),
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (fecha != null) {
                  setState(() => _fechaVencimiento = fecha);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _fechaVencimiento != null
                          ? 'Vence: ${DateFormat('dd/MM/yyyy').format(_fechaVencimiento!)}'
                          : 'Fecha vencimiento (opcional)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_suministroSeleccionado == null ||
                _cantidadController.text.isEmpty ||
                _precioCompraController.text.isEmpty) {
              return;
            }
            if (_esMedicamento && _precioVentaBaseController.text.isEmpty) {
              return;
            }

            final item = <String, dynamic>{
              'suministroId': _suministroSeleccionado!.id,
              'nombreSuministro': _suministroSeleccionado!.nombreSuministro,
              'tipo': _suministroSeleccionado!.tipo.name,
              'cantidad': double.parse(_cantidadController.text),
              'precioUnitario': double.parse(_precioCompraController.text),
              'fechaVencimiento': _fechaVencimiento != null
                  ? DateFormat('yyyy-MM-dd').format(_fechaVencimiento!)
                  : null,
            };
            if (_esMedicamento) {
              item['precioVentaBase'] =
                  double.parse(_precioVentaBaseController.text);
            }

            widget.onAgregar(item);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B5C8),
          ),
          child: const Text('Agregar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
