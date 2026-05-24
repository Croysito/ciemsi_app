import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/deuda.dart';
import '../bloc/pago_bloc.dart';
import '../bloc/pago_event.dart';
import '../bloc/pago_state.dart';

class CobrarDeudaPage extends StatefulWidget {
  final Deuda deuda;
  final int pacienteId;
  final int ciudadId;

  const CobrarDeudaPage({
    super.key,
    required this.deuda,
    required this.pacienteId,
    required this.ciudadId,
  });

  @override
  State<CobrarDeudaPage> createState() => _CobrarDeudaPageState();
}

class _CobrarDeudaPageState extends State<CobrarDeudaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _montoCtrl;
  final TextEditingController _notasCtrl = TextEditingController();
  String _metodo = 'efectivo';

  @override
  void initState() {
    super.initState();
    _montoCtrl = TextEditingController(
      text: widget.deuda.montoPendiente.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,##0.00', 'es');

    return BlocListener<PagoBloc, PagoState>(
      listener: (context, state) {
        if (state is IngresoRegistrado) {
          Navigator.pop(context, true);
        } else if (state is PagoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text(
            'Registrar Cobro',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF00B5C8),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de deuda
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.deuda.nombreTratamiento,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _resumenItem('Total deuda', widget.deuda.montoOriginal, moneyFmt),
                            _resumenItem('Ya cobrado', widget.deuda.montoCobrado, moneyFmt,
                                color: Colors.green.shade700),
                            _resumenItem('Pendiente', widget.deuda.montoPendiente, moneyFmt,
                                color: Theme.of(context).colorScheme.error),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Monto a cobrar
                TextFormField(
                  controller: _montoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monto a cobrar (Bs.)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingrese el monto';
                    final d = double.tryParse(v);
                    if (d == null || d <= 0) return 'Monto inválido';
                    if (d > widget.deuda.montoPendiente + 0.01) {
                      return 'No puede superar el pendiente';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Método de pago
                const Text('Método de pago',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: _metodo,
                  onChanged: (v) => setState(() => _metodo = v!),
                  child: Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'efectivo',
                          title: const Text('Efectivo'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'qr',
                          title: const Text('QR'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notas
                TextFormField(
                  controller: _notasCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notas (opcional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 28),

                BlocBuilder<PagoBloc, PagoState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state is PagoLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B5C8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: state is PagoLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Confirmar Cobro',
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
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<PagoBloc>().add(RegistrarCobroDeudaEvent(
          deudaId: widget.deuda.id,
          pacienteId: widget.pacienteId,
          ciudadId: widget.ciudadId,
          monto: double.parse(_montoCtrl.text),
          metodo: _metodo,
          notas: _notasCtrl.text.isEmpty ? null : _notasCtrl.text,
        ));
  }

  Widget _resumenItem(String label, double monto, NumberFormat fmt, {Color? color}) {
    return Column(
      children: [
        Text(
          'Bs. ${fmt.format(monto)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
