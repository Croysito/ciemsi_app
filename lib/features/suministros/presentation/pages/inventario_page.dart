import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_event.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_state.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/inventario_item.dart';
import 'registrar_compra_page.dart';

class InventarioPage extends StatefulWidget {
  final int ciudadId;
  final String ciudadNombre;

  const InventarioPage({
    super.key,
    required this.ciudadId,
    required this.ciudadNombre,
  });

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  @override
  void initState() {
    super.initState();
    context.read<SuministroBloc>().add(ObtenerInventarioEvent(widget.ciudadId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          'Inventario - ${widget.ciudadNombre}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SuministroBloc>().add(
              ObtenerInventarioEvent(widget.ciudadId),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.warning_outlined),
            onPressed: () => _mostrarAlertas(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8DC63F),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<SuministroBloc>(),
                child: RegistrarCompraPage(
                  ciudadId: widget.ciudadId,
                  ciudadNombre: widget.ciudadNombre,
                ),
              ),
            ),
          );
          context.read<SuministroBloc>().add(
            ObtenerInventarioEvent(widget.ciudadId),
          );
        },
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text(
          'Registrar Compra',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocBuilder<SuministroBloc, SuministroState>(
        builder: (context, state) {
          if (state is SuministroLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          if (state is SuministroError) {
            return Center(child: Text(state.mensaje));
          }
          if (state is CompraRegistrada) {
            context.read<SuministroBloc>().add(
              ObtenerInventarioEvent(widget.ciudadId),
            );
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          if (state is InventarioCargado) {
            return _buildInventario(state.inventario, state.stockBajo);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildInventario(
    List<InventarioItem> inventario,
    List<InventarioItem> stockBajo,
  ) {
    return Column(
      children: [
        // Resumen
        if (stockBajo.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_outlined, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${stockBajo.length} suministro(s) con stock bajo',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Lista
        Expanded(
          child: inventario.isEmpty
              ? const Center(
                  child: Text(
                    'No hay suministros en inventario',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: inventario.length,
                  itemBuilder: (context, index) {
                    final item = inventario[index];
                    return _buildItem(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildItem(InventarioItem item) {
    final color = item.stockBajo ? Colors.red : const Color(0xFF8DC63F);
    final porcentaje = item.umbral > 0
        ? (item.saldo / item.umbral).clamp(0.0, 2.0)
        : 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.nombreSuministro,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (item.stockBajo)
                  const Icon(
                    Icons.warning_outlined,
                    color: Colors.red,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Text(
                  '${item.saldo} ${item.unidadMedida}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: porcentaje.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tipo: ${item.tipo}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Umbral: ${item.umbral}',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarAlertas(BuildContext context) {
    context.read<SuministroBloc>().add(ObtenerAlertasEvent(widget.ciudadId));
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<SuministroBloc>(),
        child: BlocBuilder<SuministroBloc, SuministroState>(
          builder: (context, state) {
            if (state is AlertasCargadas) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ Alertas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.stockBajo.isNotEmpty) ...[
                      const Text(
                        'Stock bajo:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      ...state.stockBajo.map(
                        (s) => ListTile(
                          leading: const Icon(
                            Icons.warning_outlined,
                            color: Colors.red,
                          ),
                          title: Text(s['nombre_suministro']),
                          subtitle: Text('Saldo: ${s['saldo']}'),
                        ),
                      ),
                    ],
                    if (state.proximosAVencer.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Próximos a vencer:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      ...state.proximosAVencer.map(
                        (s) => ListTile(
                          leading: const Icon(
                            Icons.schedule,
                            color: Colors.orange,
                          ),
                          title: Text(s['nombre_suministro']),
                          subtitle: Text(
                            'Vence en ${s['dias_restantes']} días',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          },
        ),
      ),
    );
  }
}
