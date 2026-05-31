import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/cuenta_bloc.dart';
import '../bloc/cuenta_event.dart';
import '../bloc/cuenta_state.dart';
import '../../domain/entities/resumen_cuenta.dart';
import '../../domain/entities/historial_movimiento.dart';
import 'registrar_movimiento_page.dart';
import 'registrar_traspaso_page.dart';
import 'saldo_inicial_page.dart';

class CuentasPage extends StatefulWidget {
  final int? ciudadIdInicial;
  final String? ciudadNombreInicial;
  const CuentasPage({super.key, this.ciudadIdInicial, this.ciudadNombreInicial});

  @override
  State<CuentasPage> createState() => _CuentasPageState();
}

class _CuentasPageState extends State<CuentasPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  ResumenCuenta? _resumenSeleccionado;
  String _filtroTipo = 'todos';
  List<HistorialMovimiento> _historialCompleto = [];
  List<ResumenCuenta> _resumenCuentas = [];
  bool _cargandoResumen = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    context.read<CuentaBloc>().add(CargarResumenCuentasEvent(ciudadId: widget.ciudadIdInicial));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _cargarHistorial(ResumenCuenta r) {
    setState(() => _resumenSeleccionado = r);
    context.read<CuentaBloc>().add(CargarHistorialEvent(ciudadId: r.ciudadId));
    _tabCtrl.animateTo(1);
  }

  List<HistorialMovimiento> get _historialFiltrado {
    if (_filtroTipo == 'todos') return _historialCompleto;
    return _historialCompleto.where((m) => m.tipo == _filtroTipo).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Cuentas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'Resumen'),
            Tab(icon: Icon(Icons.list_alt_outlined), text: 'Historial'),
          ],
        ),
      ),
      body: BlocListener<CuentaBloc, CuentaState>(
        listener: (context, state) {
          if (state is ResumenCuentasCargado) {
            setState(() {
              _resumenCuentas = state.resumenes;
              _cargandoResumen = false;
            });
          } else if (state is HistorialCargado) {
            setState(() => _historialCompleto = state.movimientos);
          } else if (state is MovimientoExtraRegistrado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Movimiento registrado'), backgroundColor: Colors.green),
            );
            context.read<CuentaBloc>().add(CargarResumenCuentasEvent(ciudadId: widget.ciudadIdInicial));
            if (_resumenSeleccionado != null) {
              context.read<CuentaBloc>().add(CargarHistorialEvent(ciudadId: _resumenSeleccionado!.ciudadId));
            }
          } else if (state is MovimientoExtraEliminado) {
            if (_resumenSeleccionado != null) {
              context.read<CuentaBloc>().add(CargarHistorialEvent(ciudadId: _resumenSeleccionado!.ciudadId));
              context.read<CuentaBloc>().add(CargarResumenCuentasEvent(ciudadId: widget.ciudadIdInicial));
            }
          } else if (state is TraspasoRegistrado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Traspaso registrado'), backgroundColor: Colors.green),
            );
            context.read<CuentaBloc>().add(CargarResumenCuentasEvent(ciudadId: widget.ciudadIdInicial));
            if (_resumenSeleccionado != null) {
              context.read<CuentaBloc>().add(CargarHistorialEvent(ciudadId: _resumenSeleccionado!.ciudadId));
            }
          } else if (state is TraspasoEliminado) {
            if (_resumenSeleccionado != null) {
              context.read<CuentaBloc>().add(CargarHistorialEvent(ciudadId: _resumenSeleccionado!.ciudadId));
              context.read<CuentaBloc>().add(CargarResumenCuentasEvent(ciudadId: widget.ciudadIdInicial));
            }
          } else if (state is CuentaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
            );
          }
        },
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _ResumenTab(
              resumenes: _resumenCuentas,
              cargando: _cargandoResumen,
              onCiudadTap: _cargarHistorial,
            ),
            _HistorialTab(
              movimientos: _historialFiltrado,
              filtroTipo: _filtroTipo,
              ciudadSeleccionada: _resumenSeleccionado,
              onFiltroChanged: (v) => setState(() => _filtroTipo = v),
            ),
          ],
        ),
      ),
      floatingActionButton: _resumenSeleccionado == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'fab_traspaso',
                  backgroundColor: const Color(0xFF8DC63F),
                  tooltip: 'Traspaso efectivo/banco',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CuentaBloc>(),
                        child: RegistrarTraspasoPage(
                          ciudadId: _resumenSeleccionado!.ciudadId,
                          nombreCiudad: _resumenSeleccionado!.nombreCiudad,
                        ),
                      ),
                    ),
                  ),
                  child: const Icon(Icons.swap_horiz, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: 'fab_movimiento',
                  backgroundColor: const Color(0xFF00B5C8),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Registrar', style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CuentaBloc>(),
                        child: RegistrarMovimientoPage(
                          ciudadId: _resumenSeleccionado!.ciudadId,
                          nombreCiudad: _resumenSeleccionado!.nombreCiudad,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Tab Resumen ─────────────────────────────────────────────────────────────

class _ResumenTab extends StatelessWidget {
  final List<ResumenCuenta> resumenes;
  final bool cargando;
  final void Function(ResumenCuenta) onCiudadTap;

  const _ResumenTab({
    required this.resumenes,
    required this.cargando,
    required this.onCiudadTap,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B5C8)));
    }
    if (resumenes.isEmpty) {
      return const Center(child: Text('Sin datos de ciudades'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resumenes.length,
      itemBuilder: (_, i) => _TarjetaCiudad(
        resumen: resumenes[i],
        onTap: () => onCiudadTap(resumenes[i]),
      ),
    );
  }
}

class _TarjetaCiudad extends StatelessWidget {
  final ResumenCuenta resumen;
  final VoidCallback onTap;
  const _TarjetaCiudad({required this.resumen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs ', decimalDigits: 2);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_city, color: Color(0xFF00B5C8), size: 18),
                  const SizedBox(width: 6),
                  Text(resumen.nombreCiudad,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.tune_outlined, size: 18, color: Colors.grey),
                    tooltip: 'Saldo inicial',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<CuentaBloc>(),
                          child: SaldoInicialPage(
                            ciudadId: resumen.ciudadId,
                            nombreCiudad: resumen.nombreCiudad,
                            cajaActual: resumen.saldoInicialCaja,
                            bancoActual: resumen.saldoInicialBanco,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(child: _SaldoChip(
                    label: 'Caja',
                    icon: Icons.money,
                    color: const Color(0xFF00B5C8),
                    monto: resumen.saldoCaja,
                    fmt: fmt,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _SaldoChip(
                    label: 'Banco',
                    icon: Icons.account_balance_outlined,
                    color: const Color(0xFF8DC63F),
                    monto: resumen.saldoBanco,
                    fmt: fmt,
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MiniStat('↑ Ingresos', resumen.ingresosCaja + resumen.ingresosBanco, Colors.green, fmt),
                  const SizedBox(width: 12),
                  _MiniStat('↓ Egresos', resumen.egresosCaja + resumen.egresosBanco, Colors.red, fmt),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaldoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double monto;
  final NumberFormat fmt;
  const _SaldoChip({required this.label, required this.icon, required this.color, required this.monto, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 4),
          Text(fmt.format(monto),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: monto < 0 ? Colors.red : Colors.black87,
              )),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double monto;
  final Color color;
  final NumberFormat fmt;
  const _MiniStat(this.label, this.monto, this.color, this.fmt);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      const SizedBox(width: 4),
      Text(fmt.format(monto), style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    ]);
  }
}

// ─── Tab Historial ────────────────────────────────────────────────────────────

class _HistorialTab extends StatelessWidget {
  final List<HistorialMovimiento> movimientos;
  final String filtroTipo;
  final ResumenCuenta? ciudadSeleccionada;
  final void Function(String) onFiltroChanged;

  const _HistorialTab({
    required this.movimientos,
    required this.filtroTipo,
    required this.ciudadSeleccionada,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (ciudadSeleccionada == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Selecciona una ciudad en la pestaña Resumen',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return BlocBuilder<CuentaBloc, CuentaState>(
      buildWhen: (_, s) => s is CuentaLoading || s is HistorialCargado || s is CuentaError,
      builder: (context, state) {
        if (state is CuentaLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00B5C8)));
        }
        return Column(
          children: [
            // Filtro
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  Text('${ciudadSeleccionada!.nombreCiudad}  •',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 8),
                  _FiltroChip('Todos', 'todos', filtroTipo, onFiltroChanged),
                  const SizedBox(width: 6),
                  _FiltroChip('Ingresos', 'ingreso', filtroTipo, onFiltroChanged),
                  const SizedBox(width: 6),
                  _FiltroChip('Egresos', 'egreso', filtroTipo, onFiltroChanged),
                ],
              ),
            ),
            const SizedBox(height: 6),
            if (movimientos.isEmpty)
              const Expanded(child: Center(child: Text('Sin movimientos', style: TextStyle(color: Colors.grey))))
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: movimientos.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) => _MovimientoTile(
                    mov: movimientos[i],
                    onEliminar: movimientos[i].fuente == 'movimiento_extra'
                        ? () => context.read<CuentaBloc>().add(EliminarMovimientoExtraEvent(movimientos[i].id))
                        : movimientos[i].fuente == 'traspaso'
                            ? () => context.read<CuentaBloc>().add(EliminarTraspasoEvent(movimientos[i].id))
                            : null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final void Function(String) onTap;
  const _FiltroChip(this.label, this.value, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00B5C8) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}

class _MovimientoTile extends StatelessWidget {
  final HistorialMovimiento mov;
  final VoidCallback? onEliminar;
  const _MovimientoTile({required this.mov, this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs ', decimalDigits: 2);
    final esTraspaso = mov.fuente == 'traspaso';

    final Color color;
    final IconData icono;
    final String metodoLabel;

    if (esTraspaso) {
      color = const Color(0xFF7B61FF);
      icono = Icons.swap_horiz;
      metodoLabel = mov.descripcion ?? '';
    } else {
      color = mov.esIngreso ? Colors.green : Colors.red;
      icono = mov.esIngreso ? Icons.arrow_downward : Icons.arrow_upward;
      metodoLabel = mov.metodo == 'efectivo' ? 'Caja' : 'Banco';
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: esTraspaso ? color.withValues(alpha: 0.25) : Colors.grey.shade200),
      ),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icono, color: color, size: 16),
        ),
        title: Text(mov.categoria, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy HH:mm').format(mov.fecha)}  •  $metodoLabel',
          style: const TextStyle(fontSize: 11),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              esTraspaso ? fmt.format(mov.monto) : '${mov.esIngreso ? '+' : '-'}${fmt.format(mov.monto)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            if (onEliminar != null) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Eliminar movimiento'),
                    content: const Text('¿Confirmas eliminar este movimiento?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () { Navigator.pop(context); onEliminar!(); },
                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
