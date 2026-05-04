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
  final VoidCallback? onMenuTap;

  const TratamientosAsignadosPage({super.key, this.puedeGestionar = true, this.onMenuTap});

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
        leading: widget.onMenuTap != null
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: widget.onMenuTap,
              )
            : null,
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
                    color: colorEstado.withValues(alpha: 0.1),
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
  // suministroId → cantidad seleccionada
  final Map<int, int> _cantidades = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final resInsumo = await ApiClientProvider.instance.dio.get(
        '/suministros',
        queryParameters: {'tipo': 'INSUMO'},
      );
      final resMat = await ApiClientProvider.instance.dio.get(
        '/suministros',
        queryParameters: {'tipo': 'MATERIAL'},
      );
      final lista = [...(resInsumo.data as List), ...(resMat.data as List)]
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
      setState(() {
        _suministros = lista;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      debugPrint('Error cargando suministros: $e');
    }
  }

  int get _totalSeleccionados =>
      _cantidades.values.where((c) => c > 0).length;

  void _cambiarCantidad(int suministroId, int delta) {
    setState(() {
      final actual = _cantidades[suministroId] ?? 0;
      final nuevo = (actual + delta).clamp(0, 99);
      if (nuevo == 0) {
        _cantidades.remove(suministroId);
      } else {
        _cantidades[suministroId] = nuevo;
      }
    });
  }

  void _confirmar(BuildContext context) {
    final items = _cantidades.entries
        .where((e) => e.value > 0)
        .map((e) => {'suministroId': e.key, 'cantidad': e.value})
        .toList();
    if (items.isEmpty) return;
    context.read<TratamientoBloc>().add(
      AgregarMultiplesSuministrosEvent(
        tratamientoAsignadoId: widget.tratamientoAsignadoId,
        items: items,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            // Asa
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Agregar insumos / materiales',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_totalSeleccionados > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B5C8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_totalSeleccionados',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B5C8),
                      ),
                    )
                  : _suministros.isEmpty
                  ? const Center(child: Text('Sin insumos disponibles'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _suministros.length,
                      itemBuilder: (_, i) {
                        final s = _suministros[i];
                        final cantidad = _cantidades[s.id] ?? 0;
                        final seleccionado = cantidad > 0;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: seleccionado
                                ? const Color(0xFF00B5C8).withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: seleccionado
                                  ? const Color(0xFF00B5C8)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: s.tipo == TipoSuministro.MATERIAL
                                  ? const Color(0xFF8DC63F).withValues(alpha: 0.15)
                                  : const Color(0xFF00B5C8).withValues(alpha: 0.15),
                              child: Icon(
                                s.tipo == TipoSuministro.MATERIAL
                                    ? Icons.science_outlined
                                    : Icons.medication_outlined,
                                size: 18,
                                color: s.tipo == TipoSuministro.MATERIAL
                                    ? const Color(0xFF8DC63F)
                                    : const Color(0xFF00B5C8),
                              ),
                            ),
                            title: Text(
                              s.nombreSuministro,
                              style: TextStyle(
                                fontWeight: seleccionado
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              s.tipo.name,
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _BtnContador(
                                  icon: Icons.remove,
                                  onTap: seleccionado
                                      ? () => _cambiarCantidad(s.id, -1)
                                      : null,
                                ),
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '$cantidad',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: seleccionado
                                          ? const Color(0xFF00B5C8)
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                _BtnContador(
                                  icon: Icons.add,
                                  onTap: () => _cambiarCantidad(s.id, 1),
                                  activo: true,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _totalSeleccionados > 0
                      ? () => _confirmar(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B5C8),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _totalSeleccionados > 0
                        ? 'Agregar $_totalSeleccionados insumo${_totalSeleccionados > 1 ? 's' : ''}'
                        : 'Selecciona al menos uno',
                    style: TextStyle(
                      color: _totalSeleccionados > 0
                          ? Colors.white
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BtnContador extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool activo;

  const _BtnContador({
    required this.icon,
    this.onTap,
    this.activo = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null
              ? (activo
                    ? const Color(0xFF00B5C8).withValues(alpha: 0.12)
                    : Colors.grey.shade100)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null
              ? (activo ? const Color(0xFF00B5C8) : Colors.grey.shade600)
              : Colors.grey.shade300,
        ),
      ),
    );
  }
}
