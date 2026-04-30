import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_event.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_state.dart';

class CrearSuministroPage extends StatefulWidget {
  const CrearSuministroPage({super.key});

  @override
  State<CrearSuministroPage> createState() => _CrearSuministroPageState();
}

class _CrearSuministroPageState extends State<CrearSuministroPage> {
  final _nombreController = TextEditingController();
  final _marcaController = TextEditingController();
  final _umbralController = TextEditingController(text: '5');
  String _tipoSeleccionado = 'MEDICAMENTO';
  String _unidadSeleccionada = 'UNIDAD';

  final List<String> _tipos = ['MEDICAMENTO', 'INSUMO', 'MATERIAL'];
  final List<String> _unidades = [
    'UNIDAD',
    'CAJA',
    'FRASCO',
    'AMPOLLA',
    'LITRO',
    'GRAMO',
    'MILILITRO',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    _umbralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Nuevo Suministro',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<SuministroBloc, SuministroState>(
        listener: (context, state) {
          if (state is SuministroCreado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Suministro creado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is SuministroError) {
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
                'Nombre del suministro',
                _nombreController,
                Icons.medication_outlined,
              ),
              const SizedBox(height: 12),
              _buildField(
                'Marca (opcional)',
                _marcaController,
                Icons.business_outlined,
              ),
              const SizedBox(height: 12),
              _buildField(
                'Umbral de alerta',
                _umbralController,
                Icons.warning_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Tipo
              const Text(
                'Tipo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _tipoSeleccionado,
                items: _tipos,
                onChanged: (v) => setState(() => _tipoSeleccionado = v!),
              ),
              const SizedBox(height: 16),

              // Unidad
              const Text(
                'Unidad de medida',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _unidadSeleccionada,
                items: _unidades,
                onChanged: (v) => setState(() => _unidadSeleccionada = v!),
              ),
              const SizedBox(height: 32),

              BlocBuilder<SuministroBloc, SuministroState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is SuministroLoading
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
                              context.read<SuministroBloc>().add(
                                CrearSuministroEvent(
                                  nombreSuministro: _nombreController.text
                                      .trim(),
                                  unidadMedida: _unidadSeleccionada,
                                  marca: _marcaController.text.trim().isEmpty
                                      ? null
                                      : _marcaController.text.trim(),
                                  tipo: _tipoSeleccionado,
                                  umbral:
                                      int.tryParse(_umbralController.text) ?? 5,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DC63F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state is SuministroLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Guardar Suministro',
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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
