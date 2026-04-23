import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/paciente.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_bloc.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_event.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_state.dart';

class ModificarPacientePage extends StatefulWidget {
  final Paciente paciente;
  const ModificarPacientePage({super.key, required this.paciente});

  @override
  State<ModificarPacientePage> createState() => _ModificarPacientePageState();
}

class _ModificarPacientePageState extends State<ModificarPacientePage> {
  final _ciController = TextEditingController();
  final _edadController = TextEditingController();
  final _telefonoController = TextEditingController();
  DateTime? _fechaNacimiento;
  Ciudad? _ciudadSeleccionada;
  List<Ciudad> _ciudades = [];

  @override
  void initState() {
    super.initState();
    // Cargar datos actuales del paciente
    _ciController.text = widget.paciente.ci;
    _edadController.text = widget.paciente.edad?.toString() ?? '';
    _telefonoController.text = widget.paciente.telefono ?? '';
    _fechaNacimiento = widget.paciente.fechaNacimiento;
    context.read<PacienteBloc>().add(CargarCiudadesEvent());
  }

  @override
  void dispose() {
    _ciController.dispose();
    _edadController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2000),
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
          'Modificar Paciente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<PacienteBloc, PacienteState>(
        listener: (context, state) {
          if (state is CiudadesCargadas) {
            setState(() {
              _ciudades = state.ciudades;
              if (widget.paciente.ciudad != null) {
                // Buscar por id para garantizar misma referencia
                try {
                  _ciudadSeleccionada = _ciudades.firstWhere(
                    (c) => c.id == widget.paciente.ciudad!.id,
                  );
                } catch (e) {
                  _ciudadSeleccionada = null;
                }
              }
            });
          }
          if (state is PacienteModificado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paciente actualizado correctamente'),
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
              // Info no editable
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outlined,
                        color: Color(0xFF00B5C8),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.paciente.nombreCompleto,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.paciente.usuario.email,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Datos editables',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 12),

              _buildField('CI', _ciController, Icons.badge_outlined),
              const SizedBox(height: 12),
              _buildField(
                'Teléfono',
                _telefonoController,
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildField(
                'Edad',
                _edadController,
                Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Fecha nacimiento
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
              const SizedBox(height: 12),

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

              // Botón guardar
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
                                  _ciudadSeleccionada == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('CI y ciudad son requeridos'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              context.read<PacienteBloc>().add(
                                ModificarPacienteEvent(
                                  id: widget.paciente.id,
                                  ci: _ciController.text.trim(),
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
                              'Guardar Cambios',
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
