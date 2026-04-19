import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/ciudad.dart';
import '../bloc/paciente_bloc.dart';
import '../bloc/paciente_event.dart';
import '../bloc/paciente_state.dart';

class RegistrarPacientePage extends StatefulWidget {
  const RegistrarPacientePage({super.key});

  @override
  State<RegistrarPacientePage> createState() => _RegistrarPacientePageState();
}

class _RegistrarPacientePageState extends State<RegistrarPacientePage> {
  final _ciController = TextEditingController();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _telefonoController = TextEditingController();
  DateTime? _fechaNacimiento;
  Ciudad? _ciudadSeleccionada;
  List<Ciudad> _ciudades = [];

  @override
  void initState() {
    super.initState();
    context.read<PacienteBloc>().add(CargarCiudadesEvent());
  }

  @override
  void dispose() {
    _ciController.dispose();
    _nombreController.dispose();
    _edadController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF00B5C8)),
        ),
        child: child!,
      ),
    );
    if (fecha != null) setState(() => _fechaNacimiento = fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Registrar Paciente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<PacienteBloc, PacienteState>(
        listener: (context, state) {
          if (state is CiudadesCargadas) {
            setState(() => _ciudades = state.ciudades);
          }
          if (state is PacienteRegistrado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paciente registrado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is PacienteError) {
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
              _buildField('CI', _ciController, Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildField(
                'Nombre completo',
                _nombreController,
                Icons.person_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                'Edad',
                _edadController,
                Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildField(
                'Teléfono',
                _telefonoController,
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento
              GestureDetector(
                onTap: _seleccionarFecha,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF00B5C8),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _fechaNacimiento != null
                            ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!)
                            : 'Fecha de nacimiento',
                        style: TextStyle(
                          color: _fechaNacimiento != null
                              ? Colors.black
                              : Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ciudad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Ciudad>(
                    isExpanded: true,
                    hint: const Text('Seleccionar ciudad'),
                    value: _ciudadSeleccionada,
                    items: _ciudades
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.nombreCiudad),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _ciudadSeleccionada = value),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón registrar
              BlocBuilder<PacienteBloc, PacienteState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is PacienteLoading
                          ? null
                          : () {
                              if (_ciController.text.isEmpty ||
                                  _nombreController.text.isEmpty ||
                                  _ciudadSeleccionada == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'CI, nombre y ciudad son requeridos',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              context.read<PacienteBloc>().add(
                                RegistrarPacienteEvent(
                                  ci: _ciController.text.trim(),
                                  nombre: _nombreController.text.trim(),
                                  edad: int.tryParse(_edadController.text),
                                  telefono: _telefonoController.text.trim(),
                                  fechaNacimiento: _fechaNacimiento,
                                  ciudadId: _ciudadSeleccionada!.id,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DC63F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state is PacienteLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Registrar Paciente',
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
