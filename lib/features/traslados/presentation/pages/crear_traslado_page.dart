import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/traslado_ciudad_option.dart';
import '../../domain/entities/traslado_item_option.dart';
import '../bloc/traslado_bloc.dart';
import '../bloc/traslado_event.dart';
import '../bloc/traslado_state.dart';

class CrearTrasladoPage extends StatefulWidget {
  final int ciudadOrigenId;
  final String ciudadOrigenNombre;

  const CrearTrasladoPage({
    super.key,
    required this.ciudadOrigenId,
    required this.ciudadOrigenNombre,
  });

  @override
  State<CrearTrasladoPage> createState() => _CrearTrasladoPageState();
}

class _CrearTrasladoPageState extends State<CrearTrasladoPage> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadCtrl = TextEditingController();

  String _tipo = 'SUMINISTRO';
  List<TrasladoItemOption> _suministros = [];
  List<TrasladoItemOption> _productos = [];
  List<TrasladoCiudadOption> _ciudades = [];

  int? _itemSeleccionadoId;
  int? _ciudadDestinoId;
  bool _cargando = true;

  double? _stockDisponible;
  bool _cargandoStock = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    context.read<TrasladoBloc>().add(
      CargarDatosCreacionTrasladoEvent(widget.ciudadOrigenId),
    );
  }

  Future<void> _consultarStock(int itemId) async {
    setState(() {
      _stockDisponible = null;
      _cargandoStock = true;
    });
    context.read<TrasladoBloc>().add(
      ConsultarStockTrasladoEvent(
        tipo: _tipo,
        itemId: itemId,
        ciudadOrigenId: widget.ciudadOrigenId,
      ),
    );
  }

  List<TrasladoItemOption> get _itemsActuales =>
      _tipo == 'SUMINISTRO' ? _suministros : _productos;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_itemSeleccionadoId == null) {
      _showError(
        _tipo == 'SUMINISTRO'
            ? 'Selecciona un suministro'
            : 'Selecciona un producto',
      );
      return;
    }
    if (_ciudadDestinoId == null) {
      _showError('Selecciona la ciudad destino');
      return;
    }

    context.read<TrasladoBloc>().add(
      CrearTrasladoEvent(
        tipo: _tipo,
        suministroId: _tipo == 'SUMINISTRO' ? _itemSeleccionadoId : null,
        productoId: _tipo == 'PRODUCTO' ? _itemSeleccionadoId : null,
        ciudadOrigenId: widget.ciudadOrigenId,
        ciudadDestinoId: _ciudadDestinoId!,
        cantidad: double.parse(_cantidadCtrl.text.trim()),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Nuevo Traslado',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<TrasladoBloc, TrasladoState>(
        listener: (context, state) {
          if (state is TrasladoDatosCreacionCargados) {
            setState(() {
              _suministros = state.datos.suministros;
              _productos = state.datos.productos;
              _ciudades = state.datos.ciudades;
              _cargando = false;
            });
          } else if (state is TrasladoStockLoading) {
            setState(() => _cargandoStock = true);
          } else if (state is TrasladoStockCargado) {
            setState(() {
              _stockDisponible = state.disponible;
              _cargandoStock = false;
            });
          } else if (state is TrasladoOperacionExitosa) {
            Navigator.pop(context, true);
          } else if (state is TrasladoError) {
            setState(() {
              _cargando = false;
              _cargandoStock = false;
            });
            _showError(state.mensaje);
          }
        },
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Origen
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF00B5C8),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ciudad origen',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    widget.ciudadOrigenNombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tipo
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: _tipo,
                            decoration: const InputDecoration(
                              labelText: 'Tipo',
                              border: InputBorder.none,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'SUMINISTRO',
                                child: Text('Suministro'),
                              ),
                              DropdownMenuItem(
                                value: 'PRODUCTO',
                                child: Text('Producto'),
                              ),
                            ],
                            onChanged: (v) => setState(() {
                              _tipo = v!;
                              _itemSeleccionadoId = null;
                              _stockDisponible = null;
                              _cantidadCtrl.clear();
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Item
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: DropdownButtonFormField<int>(
                            initialValue: _itemSeleccionadoId,
                            decoration: InputDecoration(
                              labelText: _tipo == 'SUMINISTRO'
                                  ? 'Suministro'
                                  : 'Producto',
                              border: InputBorder.none,
                            ),
                            items: _itemsActuales
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(item.nombre),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                _itemSeleccionadoId = v;
                                _cantidadCtrl.clear();
                              });
                              if (v != null) _consultarStock(v);
                            },
                            validator: (v) => v == null ? 'Requerido' : null,
                          ),
                        ),
                      ),

                      // Badge de stock disponible
                      if (_itemSeleccionadoId != null) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _cargandoStock
                              ? const Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: Color(0xFF00B5C8),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Consultando stock...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Icon(
                                      (_stockDisponible ?? 0) <= 0
                                          ? Icons.warning_outlined
                                          : Icons.inventory_outlined,
                                      size: 14,
                                      color: (_stockDisponible ?? 0) <= 0
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _stockDisponible == null
                                          ? 'No se pudo obtener el stock'
                                          : 'Disponible en origen: ${_stockDisponible! % 1 == 0 ? _stockDisponible!.toInt() : _stockDisponible}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: (_stockDisponible ?? 0) <= 0
                                            ? Colors.red
                                            : Colors.grey,
                                        fontWeight: (_stockDisponible ?? 0) <= 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Ciudad destino
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: DropdownButtonFormField<int>(
                            initialValue: _ciudadDestinoId,
                            decoration: const InputDecoration(
                              labelText: 'Ciudad destino',
                              border: InputBorder.none,
                            ),
                            items: _ciudades
                                .map(
                                  (ciudad) => DropdownMenuItem(
                                    value: ciudad.id,
                                    child: Text(ciudad.nombre),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _ciudadDestinoId = v),
                            validator: (v) => v == null ? 'Requerido' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Cantidad
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: TextFormField(
                            controller: _cantidadCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Cantidad',
                              border: InputBorder.none,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Requerido';
                              }
                              final n = double.tryParse(v.trim());
                              if (n == null || n <= 0) {
                                return 'Ingresa un número válido mayor a 0';
                              }
                              if (_stockDisponible != null &&
                                  n > _stockDisponible!) {
                                final s = _stockDisponible!;
                                return 'Máximo disponible: ${s % 1 == 0 ? s.toInt() : s}';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      BlocBuilder<TrasladoBloc, TrasladoState>(
                        builder: (context, state) {
                          final loading = state is TrasladoLoading;
                          return FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF00B5C8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: loading ? null : _submit,
                            icon: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                            label: const Text(
                              'Crear Traslado',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
