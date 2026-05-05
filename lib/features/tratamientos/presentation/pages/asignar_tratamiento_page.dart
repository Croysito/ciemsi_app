import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_event.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_state.dart';
import 'package:ciemsi_app/features/tratamientos/domain/entities/tratamiento.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/suministro.dart';
import 'package:ciemsi_app/features/suministros/data/models/suministro_model.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';

class AsignarTratamientoPage extends StatefulWidget {
  final CitaMedica cita;

  const AsignarTratamientoPage({super.key, required this.cita});

  @override
  State<AsignarTratamientoPage> createState() => _AsignarTratamientoPageState();
}

class _AsignarTratamientoPageState extends State<AsignarTratamientoPage> {
  List<Tratamiento> _tratamientos = [];
  List<Suministro> _medicamentos = [];
  Tratamiento? _tratamientoSeleccionado;
  final _precioController = TextEditingController();
  final List<Map<String, dynamic>> _medicamentosSeleccionados = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    context.read<TratamientoBloc>().add(ListarTratamientosEvent());
  }

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final resMed = await ApiClientProvider.instance.dio.get(
        '/suministros',
        queryParameters: {'tipo': 'MEDICAMENTO'},
      );
      setState(() {
        _medicamentos = (resMed.data as List)
            .map((s) => SuministroModel.fromJson(s))
            .toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  void _onTratamientoSeleccionado(Tratamiento? value) {
    setState(() {
      _tratamientoSeleccionado = value;
      _precioController.text =
          value != null ? value.precioBase.toStringAsFixed(2) : '';

      _medicamentosSeleccionados.clear();
      if (value != null) {
        for (final med in value.medicamentosBase) {
          _medicamentosSeleccionados.add({
            'suministroId': med.suministroId,
            'nombre': med.nombreSuministro,
            'cantidad': med.cantidad,
          });
        }
      }
    });
  }

  void _agregarMedicamento() {
    final yaSeleccionados =
        _medicamentosSeleccionados.map((m) => m['suministroId'] as int).toSet();
    final disponibles =
        _medicamentos.where((m) => !yaSeleccionados.contains(m.id)).toList();

    showDialog(
      context: context,
      builder: (_) => _DialogMedicamento(
        medicamentos: disponibles,
        onAgregar: (item) =>
            setState(() => _medicamentosSeleccionados.add(item)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Asignar Tratamiento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<TratamientoBloc, TratamientoState>(
        listener: (context, state) {
          if (state is TratamientosListados) {
            setState(() => _tratamientos = state.tratamientos);
          }
          if (state is TratamientoAsignadoExito) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tratamiento asignado correctamente'),
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
              // Info cita
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cita',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        widget.cita.paciente.nombreCompleto,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${widget.cita.servicio.nombreServicio} • ${widget.cita.ciudad.nombreCiudad}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tratamiento
              const Text(
                'Tratamiento',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Tratamiento>(
                    isExpanded: true,
                    hint: const Text('Seleccionar tratamiento'),
                    value: _tratamientoSeleccionado,
                    items: _tratamientos
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              '${t.nombreTratamiento} — Bs ${t.precioBase.toStringAsFixed(2)}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _onTratamientoSeleccionado,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Precio final (editable, pre-llenado desde precioBase)
              TextField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Precio final (Bs)',
                  labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
                  prefixIcon: const Icon(
                    Icons.attach_money_outlined,
                    color: Color(0xFF00B5C8),
                  ),
                  helperText: _tratamientoSeleccionado != null
                      ? 'Precio base: Bs ${_tratamientoSeleccionado!.precioBase.toStringAsFixed(2)} — modificable'
                      : null,
                  helperStyle: const TextStyle(color: Colors.grey, fontSize: 12),
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
              const SizedBox(height: 16),

              // Medicamentos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Medicamentos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00B5C8),
                    ),
                  ),
                  _cargando
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Sin medicamentos (opcional)',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._medicamentosSeleccionados.asMap().entries.map((e) {
                  final item = e.value;
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
                      title: Text(item['nombre']),
                      subtitle: Text('Cantidad: ${item['cantidad']}'),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => setState(
                          () => _medicamentosSeleccionados.removeAt(e.key),
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 32),

              BlocBuilder<TratamientoBloc, TratamientoState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is TratamientoLoading ||
                              _tratamientoSeleccionado == null
                          ? null
                          : () {
                              context.read<TratamientoBloc>().add(
                                AsignarTratamientoEvent(
                                  tratamientoId: _tratamientoSeleccionado!.id,
                                  citaId: widget.cita.id,
                                  precio: double.tryParse(
                                    _precioController.text,
                                  ),
                                  medicamentos: _medicamentosSeleccionados
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
                              'Asignar Tratamiento',
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
}

class _DialogMedicamento extends StatefulWidget {
  final List<Suministro> medicamentos;
  final Function(Map<String, dynamic>) onAgregar;

  const _DialogMedicamento({
    required this.medicamentos,
    required this.onAgregar,
  });

  @override
  State<_DialogMedicamento> createState() => _DialogMedicamentoState();
}

class _DialogMedicamentoState extends State<_DialogMedicamento> {
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Suministro>(
            hint: const Text('Seleccionar medicamento'),
            initialValue: _seleccionado,
            items: widget.medicamentos
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text(m.nombreSuministro),
                  ),
                )
                .toList(),
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
        ],
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
