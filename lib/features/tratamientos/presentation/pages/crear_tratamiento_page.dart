import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_event.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_state.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/suministro.dart';
import 'package:ciemsi_app/features/suministros/data/models/suministro_model.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';

class CrearTratamientoPage extends StatefulWidget {
  const CrearTratamientoPage({super.key});

  @override
  State<CrearTratamientoPage> createState() => _CrearTratamientoPageState();
}

class _CrearTratamientoPageState extends State<CrearTratamientoPage> {
  final _nombreController = TextEditingController();
  final _detalleController = TextEditingController();

  List<Suministro> _medicamentosDisponibles = [];
  final List<Map<String, dynamic>> _medicamentosSeleccionados = [];
  bool _cargandoMeds = false;

  static const double _costoInsumos = 50.0;

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _detalleController.dispose();
    super.dispose();
  }

  Future<void> _cargarMedicamentos() async {
    setState(() => _cargandoMeds = true);
    try {
      final response = await ApiClientProvider.instance.dio.get(
        '/suministros',
        queryParameters: {'tipo': 'MEDICAMENTO'},
      );
      setState(() {
        _medicamentosDisponibles = (response.data as List)
            .map((s) => SuministroModel.fromJson(s))
            .toList();
        _cargandoMeds = false;
      });
    } catch (e) {
      setState(() => _cargandoMeds = false);
    }
  }

  double _calcularPrecioBase() {
    final sumaMeds = _medicamentosSeleccionados.fold<double>(
      0.0,
      (sum, med) =>
          sum + (med['precioVentaBase'] as double) * (med['cantidad'] as int),
    );
    return sumaMeds + _costoInsumos;
  }

  void _agregarMedicamento() {
    final yaSeleccionados =
        _medicamentosSeleccionados.map((m) => m['suministroId'] as int).toSet();
    final disponibles = _medicamentosDisponibles
        .where((m) => !yaSeleccionados.contains(m.id))
        .toList();

    if (disponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay más medicamentos disponibles para agregar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => _DialogSeleccionarMedicamento(
        medicamentos: disponibles,
        onAgregar: (item) => setState(() => _medicamentosSeleccionados.add(item)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final precioBase = _calcularPrecioBase();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Nuevo Tratamiento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<TratamientoBloc, TratamientoState>(
        listener: (context, state) {
          if (state is TratamientoCreado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tratamiento creado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is TratamientoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                'Nombre del tratamiento',
                _nombreController,
                Icons.healing_outlined,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detalleController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF00B5C8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF00B5C8),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Medicamentos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Medicamentos del tratamiento',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00B5C8),
                    ),
                  ),
                  _cargandoMeds
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF00B5C8),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: _agregarMedicamento,
                          icon: const Icon(
                            Icons.add,
                            color: Color(0xFF8DC63F),
                          ),
                          label: const Text(
                            'Agregar',
                            style: TextStyle(color: Color(0xFF8DC63F)),
                          ),
                        ),
                ],
              ),
              if (_medicamentosSeleccionados.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Sin medicamentos seleccionados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._medicamentosSeleccionados.asMap().entries.map((entry) {
                  final i = entry.key;
                  final med = entry.value;
                  final subtotal =
                      (med['precioVentaBase'] as double) *
                      (med['cantidad'] as int);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.medication_outlined,
                        color: Color(0xFF00B5C8),
                      ),
                      title: Text(
                        med['nombre'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Cantidad: ${med['cantidad']} × Bs ${med['precioVentaBase'].toStringAsFixed(2)} = Bs ${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            setState(() => _medicamentosSeleccionados.removeAt(i)),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 16),

              // Precio base calculado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B5C8).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF00B5C8).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          color: Color(0xFF00B5C8),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Precio base calculado',
                          style: TextStyle(
                            color: Color(0xFF00B5C8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Medicamentos:',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                        Text(
                          'Bs ${(_calcularPrecioBase() - _costoInsumos).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Insumos y materiales:',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                        Text(
                          'Bs ${_costoInsumos.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total precio base:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Bs ${precioBase.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF00B5C8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              BlocBuilder<TratamientoBloc, TratamientoState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is TratamientoLoading
                          ? null
                          : () {
                              if (_nombreController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('El nombre es requerido'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              context.read<TratamientoBloc>().add(
                                CrearTratamientoEvent(
                                  nombreTratamiento:
                                      _nombreController.text.trim(),
                                  detalle:
                                      _detalleController.text.trim().isEmpty
                                      ? null
                                      : _detalleController.text.trim(),
                                  precioBase: _calcularPrecioBase(),
                                  medicamentosBase: _medicamentosSeleccionados
                                      .map(
                                        (m) => {
                                          'suministroId': m['suministroId'],
                                          'cantidad': m['cantidad'],
                                        },
                                      )
                                      .toList(),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DC63F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state is TratamientoLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Guardar Tratamiento',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
        prefixIcon: Icon(icon, color: const Color(0xFF00B5C8)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00B5C8), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _DialogSeleccionarMedicamento extends StatefulWidget {
  final List<Suministro> medicamentos;
  final Function(Map<String, dynamic>) onAgregar;

  const _DialogSeleccionarMedicamento({
    required this.medicamentos,
    required this.onAgregar,
  });

  @override
  State<_DialogSeleccionarMedicamento> createState() =>
      _DialogSeleccionarMedicamentoState();
}

class _DialogSeleccionarMedicamentoState
    extends State<_DialogSeleccionarMedicamento> {
  Suministro? _seleccionado;
  final _cantidadController = TextEditingController();

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Medicamento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Suministro>(
              hint: const Text('Seleccionar medicamento'),
              initialValue: _seleccionado,
              items: widget.medicamentos.map((m) {
                final tienePreicio = m.precioVentaBase != null;
                return DropdownMenuItem(
                  value: m,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m.nombreSuministro),
                      Text(
                        tienePreicio
                            ? 'Bs ${m.precioVentaBase!.toStringAsFixed(2)} / unidad'
                            : 'Sin precio registrado',
                        style: TextStyle(
                          fontSize: 11,
                          color: tienePreicio
                              ? Colors.grey
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _seleccionado = v),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_seleccionado != null &&
                _seleccionado!.precioVentaBase == null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_outlined,
                        color: Colors.orange, size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Este medicamento no tiene compras registradas. Su precio base será Bs 0.00.',
                        style:
                            TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            if (_seleccionado == null || _cantidadController.text.isEmpty) {
              return;
            }
            widget.onAgregar({
              'suministroId': _seleccionado!.id,
              'nombre': _seleccionado!.nombreSuministro,
              'cantidad': int.parse(_cantidadController.text),
              'precioVentaBase': _seleccionado!.precioVentaBase ?? 0.0,
            });
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
