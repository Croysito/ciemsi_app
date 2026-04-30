import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_event.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_state.dart';

class CrearTratamientoPage extends StatefulWidget {
  const CrearTratamientoPage({super.key});

  @override
  State<CrearTratamientoPage> createState() => _CrearTratamientoPageState();
}

class _CrearTratamientoPageState extends State<CrearTratamientoPage> {
  final _nombreController = TextEditingController();
  final _detalleController = TextEditingController();
  final _precioController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _detalleController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Nuevo Tratamiento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<TratamientoBloc, TratamientoState>(
        listener: (context, state) {
          if (state is TratamientoCreado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tratamiento creado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is TratamientoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                'Nombre del tratamiento',
                _nombreController,
                Icons.healing_outlined,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detalleController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF00B5C8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF00B5C8),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildField(
                'Precio base (Bs)',
                _precioController,
                Icons.attach_money_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<TratamientoBloc, TratamientoState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is TratamientoLoading
                          ? null
                          : () {
                              if (_nombreController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('El nombre es requerido'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              context.read<TratamientoBloc>().add(
                                CrearTratamientoEvent(
                                  nombreTratamiento: _nombreController.text
                                      .trim(),
                                  detalle:
                                      _detalleController.text.trim().isEmpty
                                      ? null
                                      : _detalleController.text.trim(),
                                  precioBase: double.tryParse(
                                    _precioController.text,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DC63F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state is TratamientoLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Guardar Tratamiento',
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

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
        prefixIcon: Icon(icon, color: const Color(0xFF00B5C8)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00B5C8), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
