import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/app_dependencies.dart';
import '../../domain/entities/deuda.dart';
import '../../domain/entities/ingreso.dart';
import '../bloc/pago_bloc.dart';
import '../bloc/pago_event.dart';
import '../bloc/pago_state.dart';

class HistorialPagosPacientePage extends StatefulWidget {
  const HistorialPagosPacientePage({super.key});

  @override
  State<HistorialPagosPacientePage> createState() =>
      _HistorialPagosPacientePageState();
}

class _HistorialPagosPacientePageState
    extends State<HistorialPagosPacientePage> {
  late final PagoBloc _pagoBloc;
  int? _pacienteId;

  @override
  void initState() {
    super.initState();
    _pagoBloc = AppDependencies.createPagoBloc();
    _pagoBloc.add(CargarMiPerfilPacienteEvent());
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
      child: BlocConsumer<PagoBloc, PagoState>(
        listener: (context, state) {
          if (state is MiPerfilPacienteCargado) {
            _pacienteId = state.pacienteId;
            _pagoBloc.add(ObtenerEstadoCuentaEvent(state.pacienteId));
          }
        },
        buildWhen: (_, curr) =>
            curr is PagoLoading ||
            curr is PagoError ||
            curr is MiPerfilPacienteCargado ||
            curr is EstadoCuentaObtenido,
        builder: (context, state) {
          if (state is PagoLoading || state is MiPerfilPacienteCargado) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is PagoError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.mensaje, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          _pagoBloc.add(CargarMiPerfilPacienteEvent()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is EstadoCuentaObtenido && _pacienteId != null) {
            return _HistorialPagosPacienteView(pacienteId: _pacienteId!);
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

class _HistorialPagosPacienteView extends StatelessWidget {
  final int pacienteId;
  const _HistorialPagosPacienteView({required this.pacienteId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd/MM/yyyy', 'es');
    final moneyFmt = NumberFormat('#,##0.00', 'es');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Mis Pagos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<PagoBloc, PagoState>(
        builder: (context, state) {
          if (state is PagoLoading) {
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
                    onPressed: () => context
                        .read<PagoBloc>()
                        .add(ObtenerEstadoCuentaEvent(pacienteId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is EstadoCuentaObtenido) {
            final ec = state.estadoCuenta;
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<PagoBloc>()
                  .add(ObtenerEstadoCuentaEvent(pacienteId)),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _resumenCard(ec.totalDeuda, ec.totalCobrado, ec.totalPendiente, moneyFmt, cs),
                  const SizedBox(height: 16),
                  if (ec.deudas.isNotEmpty) ...[
                    _sectionTitle('Mis deudas'),
                    const SizedBox(height: 8),
                    ...ec.deudas.map((d) => _deudaCard(d, moneyFmt, cs)),
                    const SizedBox(height: 16),
                  ],
                  if (ec.ingresos.isNotEmpty) ...[
                    _sectionTitle('Mis pagos'),
                    const SizedBox(height: 8),
                    ...ec.ingresos.map((i) => _ingresoCard(i, moneyFmt, dateFmt, cs)),
                  ],
                  if (ec.deudas.isEmpty && ec.ingresos.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Sin movimientos registrados',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _sectionTitle(String title) =>
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));

  Widget _resumenCard(
    double totalDeuda,
    double cobrado,
    double pendiente,
    NumberFormat fmt,
    ColorScheme cs,
  ) {
    return Card(
      color: cs.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Mi Resumen de Pagos',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statCol('Total deuda', 'Bs. ${fmt.format(totalDeuda)}',
                    cs.onPrimaryContainer),
                _statCol('Cobrado', 'Bs. ${fmt.format(cobrado)}',
                    Colors.green.shade700),
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

  Widget _statCol(String label, String valor, Color color) => Column(
        children: [
          Text(valor,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      );

  Widget _deudaCard(Deuda deuda, NumberFormat fmt, ColorScheme cs) {
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
                  child: Text(deuda.nombreTratamiento,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: pagada
                        ? Colors.green.withValues(alpha: 0.1)
                        : cs.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    pagada ? 'Pagada' : 'Pendiente',
                    style: TextStyle(
                      fontSize: 11,
                      color: pagada ? Colors.green.shade700 : cs.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _montoCol('Total', deuda.montoOriginal, fmt),
                _montoCol('Cobrado', deuda.montoCobrado, fmt,
                    color: Colors.green.shade700),
                _montoCol('Pendiente', deuda.montoPendiente, fmt,
                    color: deuda.montoPendiente > 0 ? cs.error : null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ingresoCard(
    Ingreso ingreso,
    NumberFormat fmt,
    DateFormat dateFmt,
    ColorScheme cs,
  ) {
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
          ingreso.esCobroDeuda ? 'Pago de deuda' : 'Compra de producto',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${dateFmt.format(ingreso.fecha)}  •  '
          '${ingreso.metodo == 'efectivo' ? 'Efectivo' : 'QR'}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          'Bs. ${fmt.format(ingreso.monto)}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }

  Widget _montoCol(String label, double monto, NumberFormat fmt, {Color? color}) =>
      Column(
        children: [
          Text(
            'Bs. ${fmt.format(monto)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
}
