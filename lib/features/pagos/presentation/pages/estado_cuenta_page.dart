import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/app_dependencies.dart';
import '../../domain/entities/deuda.dart';
import '../../domain/entities/ingreso.dart';
import '../bloc/pago_bloc.dart';
import '../bloc/pago_event.dart';
import '../bloc/pago_state.dart';
import 'cobrar_deuda_page.dart';
import 'venta_producto_page.dart';

class EstadoCuentaPage extends StatefulWidget {
  final int pacienteId;
  final int ciudadId;
  final String nombrePaciente;

  const EstadoCuentaPage({
    super.key,
    required this.pacienteId,
    required this.ciudadId,
    required this.nombrePaciente,
  });

  @override
  State<EstadoCuentaPage> createState() => _EstadoCuentaPageState();
}

class _EstadoCuentaPageState extends State<EstadoCuentaPage> {
  late final PagoBloc _pagoBloc;

  @override
  void initState() {
    super.initState();
    _pagoBloc = AppDependencies.createPagoBloc()
      ..add(ObtenerEstadoCuentaEvent(widget.pacienteId));
  }

  @override
  void dispose() {
    _pagoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _pagoBloc,
      child: _EstadoCuentaView(
        pacienteId: widget.pacienteId,
        ciudadId: widget.ciudadId,
        nombrePaciente: widget.nombrePaciente,
      ),
    );
  }
}

class _EstadoCuentaView extends StatelessWidget {
  final int pacienteId;
  final int ciudadId;
  final String nombrePaciente;

  const _EstadoCuentaView({
    required this.pacienteId,
    required this.ciudadId,
    required this.nombrePaciente,
  });

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,##0.00', 'es');
    final dateFmt = DateFormat('dd/MM/yyyy', 'es');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          nombrePaciente,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<PagoBloc>(),
                child: VentaProductoPage(
                  pacienteId: pacienteId,
                  ciudadId: ciudadId,
                ),
              ),
            ),
          );
          if (result == true && context.mounted) {
            context.read<PagoBloc>().add(ObtenerEstadoCuentaEvent(pacienteId));
          }
        },
        icon: const Icon(Icons.shopping_cart_outlined),
        label: const Text('Venta'),
        backgroundColor: const Color(0xFF8DC63F),
      ),
      body: BlocConsumer<PagoBloc, PagoState>(
        listener: (context, state) {
          if (state is IngresoEliminado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pago eliminado'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<PagoBloc>().add(ObtenerEstadoCuentaEvent(pacienteId));
          } else if (state is PagoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is PagoLoading || state is IngresoEliminado) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PagoError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.mensaje, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<PagoBloc>().add(
                      ObtenerEstadoCuentaEvent(pacienteId),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is EstadoCuentaObtenido) {
            final ec = state.estadoCuenta;
            return RefreshIndicator(
              onRefresh: () async => context.read<PagoBloc>().add(
                ObtenerEstadoCuentaEvent(pacienteId),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _resumenCard(
                    ec.totalDeuda,
                    ec.totalCobrado,
                    ec.totalPendiente,
                    moneyFmt,
                    context,
                  ),
                  const SizedBox(height: 16),
                  if (ec.deudas.isNotEmpty) ...[
                    _sectionTitle('Deudas de tratamientos'),
                    const SizedBox(height: 8),
                    ...ec.deudas.map((d) => _deudaCard(d, moneyFmt, context)),
                    const SizedBox(height: 16),
                  ],
                  if (ec.ingresos.isNotEmpty) ...[
                    _sectionTitle('Historial de pagos'),
                    const SizedBox(height: 8),
                    ...ec.ingresos.map(
                      (i) => _ingresoCard(context, i, ec.deudas, moneyFmt, dateFmt),
                    ),
                  ],
                  if (ec.deudas.isEmpty && ec.ingresos.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Sin movimientos',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget _resumenCard(
    double totalDeuda,
    double cobrado,
    double pendiente,
    NumberFormat fmt,
    BuildContext context,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Resumen',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statCol(
                  'Monto Total',
                  'Bs. ${fmt.format(totalDeuda)}',
                  cs.onPrimaryContainer,
                ),
                _statCol(
                  'Cobrado',
                  'Bs. ${fmt.format(cobrado)}',
                  Colors.green.shade700,
                ),
                _statCol(
                  'Pendiente',
                  'Bs. ${fmt.format(pendiente)}',
                  pendiente > 0 ? cs.error : Colors.green.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String label, String valor, Color color) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 13,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _deudaCard(Deuda deuda, NumberFormat fmt, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pagada = deuda.estaPagada;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    deuda.nombreTratamiento,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _estadoChip(
                  pagada ? 'Pagada' : 'Pendiente',
                  pagada ? Colors.green.shade700 : cs.error,
                  pagada
                      ? Colors.green.withValues(alpha: 0.1)
                      : cs.errorContainer,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _montoCol('Total', deuda.montoOriginal, fmt),
                _montoCol(
                  'Cobrado',
                  deuda.montoCobrado,
                  fmt,
                  color: Colors.green.shade700,
                ),
                _montoCol(
                  'Pendiente',
                  deuda.montoPendiente,
                  fmt,
                  color: deuda.montoPendiente > 0 ? cs.error : null,
                ),
              ],
            ),
            if (!pagada) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<PagoBloc>(),
                          child: CobrarDeudaPage(
                            deuda: deuda,
                            pacienteId: pacienteId,
                            ciudadId: ciudadId,
                          ),
                        ),
                      ),
                    );
                    if (result == true && context.mounted) {
                      context.read<PagoBloc>().add(
                        ObtenerEstadoCuentaEvent(pacienteId),
                      );
                    }
                  },
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Registrar Cobro'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00B5C8),
                    side: const BorderSide(color: Color(0xFF00B5C8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ingresoCard(
    BuildContext context,
    Ingreso ingreso,
    List<Deuda> deudas,
    NumberFormat fmt,
    DateFormat dateFmt,
  ) {
    final subtitulo = StringBuffer('${dateFmt.format(ingreso.fecha)}  •  ${ingreso.metodoLabel}');
    if (ingreso.esMixto) {
      subtitulo.write(
        ' (Ef. ${fmt.format(ingreso.montoEfectivo)} + QR ${fmt.format(ingreso.montoQr)})',
      );
    }
    if (ingreso.fueEditado) subtitulo.write('  •  editado');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          ingreso.esCobroDeuda
              ? Icons.payments_outlined
              : Icons.shopping_cart_outlined,
          color: const Color(0xFF00B5C8),
        ),
        title: Text(
          ingreso.esCobroDeuda ? 'Cobro de deuda' : 'Venta de producto',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(subtitulo.toString(), style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bs. ${fmt.format(ingreso.monto)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
              onSelected: (accion) {
                if (accion == 'editar') {
                  _editarIngreso(context, ingreso, deudas);
                } else if (accion == 'eliminar') {
                  _confirmarEliminar(context, ingreso, fmt);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editarIngreso(
    BuildContext context,
    Ingreso ingreso,
    List<Deuda> deudas,
  ) async {
    bool? result;
    if (ingreso.esCobroDeuda) {
      final deudaId = ingreso.deuda?['id'];
      final match = deudas.where((d) => d.id == deudaId);
      if (match.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró la deuda asociada a este pago')),
        );
        return;
      }
      result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<PagoBloc>(),
            child: CobrarDeudaPage(
              deuda: match.first,
              pacienteId: pacienteId,
              ciudadId: ciudadId,
              ingresoAEditar: ingreso,
            ),
          ),
        ),
      );
    } else {
      result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<PagoBloc>(),
            child: VentaProductoPage(
              pacienteId: pacienteId,
              ciudadId: ciudadId,
              ingresoAEditar: ingreso,
            ),
          ),
        ),
      );
    }
    if (result == true && context.mounted) {
      context.read<PagoBloc>().add(ObtenerEstadoCuentaEvent(pacienteId));
    }
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    Ingreso ingreso,
    NumberFormat fmt,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar pago'),
        content: Text(
          '¿Seguro que quieres eliminar este ${ingreso.esCobroDeuda ? "cobro" : "venta"} de '
          'Bs. ${fmt.format(ingreso.monto)}?\n\n'
          '${ingreso.esCobroDeuda ? 'La deuda volverá a quedar pendiente por ese monto.' : 'El stock de los productos vendidos se restaurará.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      context.read<PagoBloc>().add(EliminarIngresoEvent(ingreso.id));
    }
  }

  Widget _montoCol(
    String label,
    double monto,
    NumberFormat fmt, {
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          'Bs. ${fmt.format(monto)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _estadoChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
