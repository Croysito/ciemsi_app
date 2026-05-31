import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cuenta_bloc.dart';
import '../bloc/cuenta_event.dart';
import '../bloc/cuenta_state.dart';

class SaldoInicialPage extends StatefulWidget {
  final int ciudadId;
  final String nombreCiudad;
  final double cajaActual;
  final double bancoActual;
  const SaldoInicialPage({
    super.key,
    required this.ciudadId,
    required this.nombreCiudad,
    required this.cajaActual,
    required this.bancoActual,
  });

  @override
  State<SaldoInicialPage> createState() => _SaldoInicialPageState();
}

class _SaldoInicialPageState extends State<SaldoInicialPage> {
  final _cajaCtrl  = TextEditingController();
  final _bancoCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cajaCtrl.text  = widget.cajaActual.toStringAsFixed(2);
    _bancoCtrl.text = widget.bancoActual.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _cajaCtrl.dispose();
    _bancoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final caja  = double.tryParse(_cajaCtrl.text.replaceAll(',', '.'))  ?? 0;
    final banco = double.tryParse(_bancoCtrl.text.replaceAll(',', '.')) ?? 0;
    context.read<CuentaBloc>()
      ..add(SetSaldoInicialEvent(ciudadId: widget.ciudadId, tipo: 'caja',  monto: caja))
      ..add(SetSaldoInicialEvent(ciudadId: widget.ciudadId, tipo: 'banco', monto: banco));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CuentaBloc, CuentaState>(
      listener: (context, state) {
        if (state is SaldoInicialActualizado) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saldo inicial actualizado'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else if (state is CuentaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: Text('Saldo inicial — ${widget.nombreCiudad}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF00B5C8),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Define el monto de apertura para cada cuenta. Este valor se suma a todos los movimientos registrados.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                _CampoSaldo(
                  label: 'Saldo inicial Caja (efectivo)',
                  icon: Icons.money,
                  controller: _cajaCtrl,
                ),
                const SizedBox(height: 16),
                _CampoSaldo(
                  label: 'Saldo inicial Banco (QR/transferencia)',
                  icon: Icons.account_balance_outlined,
                  controller: _bancoCtrl,
                ),
                const SizedBox(height: 32),
                BlocBuilder<CuentaBloc, CuentaState>(
                  builder: (context, state) => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is CuentaLoading ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B5C8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: state is CuentaLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Text('Guardar',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CampoSaldo extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  const _CampoSaldo({required this.label, required this.icon, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 16, color: const Color(0xFF00B5C8)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: 'Bs ',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Requerido';
            final n = double.tryParse(v.replaceAll(',', '.'));
            if (n == null || n < 0) return 'Monto inválido';
            return null;
          },
        ),
      ],
    );
  }
}
