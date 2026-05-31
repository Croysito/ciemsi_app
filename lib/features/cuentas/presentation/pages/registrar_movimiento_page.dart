import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cuenta_bloc.dart';
import '../bloc/cuenta_event.dart';
import '../bloc/cuenta_state.dart';

const _categoriasEgreso = [
  ('alquiler',       'Alquiler'),
  ('pago_empleados', 'Pago empleados'),
  ('expensas',       'Expensas'),
  ('luz',            'Luz'),
  ('internet',       'Internet'),
  ('refrigerio',     'Refrigerio'),
  ('equipos',        'Equipos'),
  ('otro',           'Otro'),
];

const _categoriasIngreso = [
  ('otro', 'Otro ingreso'),
];

class RegistrarMovimientoPage extends StatefulWidget {
  final int ciudadId;
  final String nombreCiudad;
  const RegistrarMovimientoPage({super.key, required this.ciudadId, required this.nombreCiudad});

  @override
  State<RegistrarMovimientoPage> createState() => _RegistrarMovimientoPageState();
}

class _RegistrarMovimientoPageState extends State<RegistrarMovimientoPage> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'egreso';
  String _categoria = 'alquiler';
  String _metodo = 'efectivo';
  final _montoCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();

  List<(String, String)> get _categorias =>
      _tipo == 'egreso' ? _categoriasEgreso : _categoriasIngreso;

  @override
  void dispose() {
    _montoCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final monto = double.tryParse(_montoCtrl.text.replaceAll(',', '.')) ?? 0;
    context.read<CuentaBloc>().add(RegistrarMovimientoExtraEvent(
      tipo: _tipo,
      categoria: _categoria,
      descripcion: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      monto: monto,
      metodo: _metodo,
      ciudadId: widget.ciudadId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CuentaBloc, CuentaState>(
      listener: (context, state) {
        if (state is MovimientoExtraRegistrado) Navigator.pop(context);
        if (state is CuentaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: Text('Registrar movimiento — ${widget.nombreCiudad}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                // Tipo
                const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(children: [
                  _buildTipoBtn('Egreso', 'egreso', Icons.arrow_upward, Colors.red),
                  const SizedBox(width: 12),
                  _buildTipoBtn('Ingreso', 'ingreso', Icons.arrow_downward, Colors.green),
                ]),
                const SizedBox(height: 20),

                // Categoría
                const Text('Categoría', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categorias.map((c) {
                    final sel = _categoria == c.$1;
                    return GestureDetector(
                      onTap: () => setState(() => _categoria = c.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFF00B5C8) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? const Color(0xFF00B5C8) : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(c.$2,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Descripción (si es "otro" es obligatoria)
                if (_categoria == 'otro') ...[
                  const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: _inputDeco('Descripción del movimiento'),
                    validator: (v) => (_categoria == 'otro' && (v == null || v.trim().isEmpty))
                        ? 'La descripción es requerida para "Otro"'
                        : null,
                  ),
                  const SizedBox(height: 20),
                ],

                // Monto
                const Text('Monto (Bs)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _montoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDeco('0.00'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa el monto';
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    if (n == null || n <= 0) return 'Monto inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Método
                const Text('Método de pago', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(children: [
                  _buildMetodoBtn('Efectivo', 'efectivo', Icons.money),
                  const SizedBox(width: 12),
                  _buildMetodoBtn('Transferencia', 'transferencia', Icons.account_balance_outlined),
                ]),
                const SizedBox(height: 32),

                // Botón
                BlocBuilder<CuentaBloc, CuentaState>(
                  builder: (context, state) {
                    final loading = state is CuentaLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B5C8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : const Text('Registrar',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildTipoBtn(String label, String value, IconData icon, Color color) {
    final sel = _tipo == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tipo = value;
          _categoria = value == 'egreso' ? 'alquiler' : 'otro';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? color.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? color : Colors.grey.shade300, width: sel ? 2 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: sel ? color : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: sel ? color : Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetodoBtn(String label, String value, IconData icon) {
    final sel = _metodo == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _metodo = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF00B5C8).withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sel ? const Color(0xFF00B5C8) : Colors.grey.shade300,
              width: sel ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: sel ? const Color(0xFF00B5C8) : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    color: sel ? const Color(0xFF00B5C8) : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
