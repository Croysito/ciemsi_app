import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_event.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_state.dart';
import 'package:ciemsi_app/features/tratamientos/domain/entities/tratamiento_asignado.dart'
    as entidad;
import 'package:ciemsi_app/features/suministros/domain/entities/suministro.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';

class TratamientosAsignadosPage extends StatefulWidget {
  final bool puedeGestionar;

  const TratamientosAsignadosPage({super.key, this.puedeGestionar = true});

  @override
  State<TratamientosAsignadosPage> createState() =>
      _TratamientosAsignadosPageState();
}

class _TratamientosAsignadosPageState extends State<TratamientosAsignadosPage> {
  @override
  void initState() {
    super.initState();
    context.read<TratamientoBloc>().add(ListarAsignadosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Tratamientos Asignados',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<TratamientoBloc>().add(ListarAsignadosEvent()),
          ),
        ],
      ),
      body: BlocBuilder<TratamientoBloc, TratamientoState>(
        builder: (context, state) {
          if (state is TratamientoLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          if (state is TratamientoCompletado || state is SuministroAgregado) {
            context.read<TratamientoBloc>().add(ListarAsignadosEvent());
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          if (state is TratamientosAsignadosListados) {
            if (state.tratamientos.isEmpty) {
              return const Center(
                child: Text(
                  'No hay tratamientos asignados',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tratamientos.length,
              itemBuilder: (context, index) {
                final t = state.tratamientos[index];
                return _buildCard(context, t);
              },
            );
          }
          if (state is TratamientoError) {
            return Center(child: Text(state.mensaje));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, entidad.TratamientoAsignado t) {
    final estaCompletado = t.estado == 'COMPLETADO';
    final colorEstado = estaCompletado
        ? const Color(0xFF8DC63F)
        : t.estado == 'EN_PROCESO'
        ? const Color(0xFF00B5C8)
        : Colors.orange;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.tratamiento.nombreTratamiento,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    t.estado,
                    style: TextStyle(
                      color: colorEstado,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${t.cita['paciente']?['nombreCompleto'] ?? 'Paciente'} • ${t.ciudadNombre}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(t.cita['fecha'].toString()))}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              'Precio: Bs ${t.precio.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF8DC63F),
                fontWeight: FontWeight.bold,
              ),
            ),

            // Suministros
            if (widget.puedeGestionar && t.suministros.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const Text(
                'Suministros:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              ...t.suministros.map(
                (s) => Row(
                  children: [
                    Icon(
                      s.suministro.tipo == TipoSuministro.MEDICAMENTO
                          ? Icons.medication_outlined
                          : Icons.science_outlined,
                      size: 14,
                      color: s.agregadoPor == 'DOCTORA'
                          ? const Color(0xFF00B5C8)
                          : const Color(0xFF8DC63F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${s.suministro.nombreSuministro} x${s.cantidad}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${s.agregadoPor})',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Acciones asistente
            if (widget.puedeGestionar && !estaCompletado) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _agregarSuministro(context, t.id),
                      icon: const Icon(
                        Icons.add,
                        color: Color(0xFF8DC63F),
                        size: 16,
                      ),
                      label: const Text(
                        'Agregar insumo',
                        style: TextStyle(
                          color: Color(0xFF8DC63F),
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8DC63F)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completar(context, t.id),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text(
                        'Completar',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B5C8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _agregarSuministro(BuildContext context, int tratamientoAsignadoId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<TratamientoBloc>(),
        child: _BottomSheetSuministro(
          tratamientoAsignadoId: tratamientoAsignadoId,
        ),
      ),
    );
  }

  void _completar(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Completar Tratamiento'),
        content: const Text(
          '¿Confirmas que el tratamiento fue aplicado? El inventario se actualizará automáticamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TratamientoBloc>().add(
                CompletarTratamientoEvent(id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8DC63F),
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetSuministro extends StatefulWidget {
  final int tratamientoAsignadoId;

  const _BottomSheetSuministro({required this.tratamientoAsignadoId});

  @override
  State<_BottomSheetSuministro> createState() => _BottomSheetSuministroState();
}

class _BottomSheetSuministroState extends State<_BottomSheetSuministro> {
  List<Suministro> _suministros = [];
  Suministro? _seleccionado;
  final _cantidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final response = await ApiClientProvider.instance.dio.get(
        '/suministros',
        queryParameters: {'tipo': 'INSUMO'},
      );
      final resMat = await ApiClientProvider.instance.dio.get(
        '/suministros',
        queryParameters: {'tipo': 'MATERIAL'},
      );
      setState(() {
        _suministros = [...(response.data as List), ...(resMat.data as List)]
            .map(
              (s) => Suministro(
                id: s['id'],
                nombreSuministro: s['nombreSuministro'],
                unidadMedida: UnidadMedida.values.firstWhere(
                  (e) => e.name == s['unidadMedida'],
                  orElse: () => UnidadMedida.UNIDAD,
                ),
                tipo: TipoSuministro.values.firstWhere(
                  (e) => e.name == s['tipo'],
                  orElse: () => TipoSuministro.INSUMO,
                ),
                umbral: s['umbral'] ?? 5,
                estado: s['estado'] ?? true,
              ),
            )
            .toList();
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agregar Insumo/Material',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Suministro>(
            hint: const Text('Seleccionar insumo o material'),
            value: _seleccionado,
            items: _suministros
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text('${s.nombreSuministro} (${s.tipo.name})'),
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_seleccionado == null || _cantidadController.text.isEmpty)
                  return;
                context.read<TratamientoBloc>().add(
                  AgregarSuministroEvent(
                    tratamientoAsignadoId: widget.tratamientoAsignadoId,
                    suministroId: _seleccionado!.id,
                    cantidad: int.parse(_cantidadController.text),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B5C8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Agregar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
