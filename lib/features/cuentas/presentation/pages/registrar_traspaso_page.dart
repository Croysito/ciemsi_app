import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cuenta_bloc.dart';
import '../bloc/cuenta_event.dart';
import '../bloc/cuenta_state.dart';

class RegistrarTraspasoPage extends StatefulWidget {
  final int ciudadId;
  final String nombreCiudad;
  const RegistrarTraspasoPage({
    super.key,
    required this.ciudadId,
    required this.nombreCiudad,
  });

  @override
  State<RegistrarTraspasoPage> createState() => _RegistrarTraspasoPageState();
}

class _RegistrarTraspasoPageState extends State<RegistrarTraspasoPage> {
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _tipo = 'efectivo_a_banco';

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Registrar Traspaso',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<CuentaBloc, CuentaState>(
        listener: (context, state) {
          if (state is TraspasoRegistrado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Traspaso registrado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is CuentaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ciudad
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.location_city_outlined, color: Color(0xFF00B5C8)),
                      const SizedBox(width: 12),
                      Text(
                        widget.nombreCiudad,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Dirección del traspaso',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00B5C8)),
              ),
              const SizedBox(height: 12),

              // Selector de dirección
              Row(
                children: [
                  Expanded(child: _buildOpcion('efectivo_a_banco', 'Efectivo → Banco', Icons.arrow_forward)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildOpcion('banco_a_efectivo', 'Banco → Efectivo', Icons.arrow_back)),
                ],
              ),
              const SizedBox(height: 20),

              // Descripción visual
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B5C8).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00B5C8).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCuentaChip(
                      _tipo == 'efectivo_a_banco' ? 'Caja' : 'Banco',
                      _tipo == 'efectivo_a_banco' ? Icons.money : Icons.account_balance_outlined,
                      Colors.red,
                      'Sale de',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.swap_horiz, color: Color(0xFF00B5C8), size: 32),
                    ),
                    _buildCuentaChip(
                      _tipo == 'efectivo_a_banco' ? 'Banco' : 'Caja',
                      _tipo == 'efectivo_a_banco' ? Icons.account_balance_outlined : Icons.money,
                      Colors.green,
                      'Entra a',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Monto
              TextField(
                controller: _montoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monto (Bs)',
                  labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
                  prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF00B5C8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF00B5C8), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Descripción opcional
              TextField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
                  prefixIcon: const Icon(Icons.notes_outlined, color: Color(0xFF00B5C8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF00B5C8), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              BlocBuilder<CuentaBloc, CuentaState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is CuentaLoading ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B5C8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: state is CuentaLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Registrar Traspaso',
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

  Widget _buildOpcion(String valor, String etiqueta, IconData icono) {
    final seleccionado = _tipo == valor;
    return GestureDetector(
      onTap: () => setState(() => _tipo = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF00B5C8) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? const Color(0xFF00B5C8) : Colors.grey.shade300,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: seleccionado ? Colors.white : Colors.grey, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                etiqueta,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: seleccionado ? Colors.white : Colors.black87,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuentaChip(String nombre, IconData icono, Color color, String etiqueta) {
    return Column(
      children: [
        Text(etiqueta, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icono, color: color, size: 18),
              const SizedBox(width: 6),
              Text(nombre, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ],
    );
  }

  void _guardar() {
    final monto = double.tryParse(_montoController.text.replaceAll(',', '.'));
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un monto válido mayor a cero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final descripcion = _descripcionController.text.trim();
    context.read<CuentaBloc>().add(
      RegistrarTraspasoEvent(
        tipo: _tipo,
        monto: monto,
        descripcion: descripcion.isEmpty ? null : descripcion,
        ciudadId: widget.ciudadId,
      ),
    );
  }
}
