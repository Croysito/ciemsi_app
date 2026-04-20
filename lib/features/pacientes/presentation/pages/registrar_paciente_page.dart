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
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
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
    _apellidoController.dispose();
    _emailController.dispose();
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

  void _mostrarCredenciales(String email, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Paciente Registrado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparte estas credenciales con el paciente:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildCredencial('Email', email),
            const SizedBox(height: 8),
            _buildCredencial('Contraseña', password),
            const SizedBox(height: 12),
            const Text(
              '⚠️ La contraseña es el CI del paciente.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // cierra dialog
              Navigator.pop(context, true); // vuelve a lista
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B5C8),
            ),
            child: const Text(
              'Entendido',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredencial(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            _mostrarCredenciales(state.email, state.password);
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
              const Text(
                'Datos personales',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 12),
              _buildField('CI', _ciController, Icons.badge_outlined),
              const SizedBox(height: 12),
              _buildField('Nombre', _nombreController, Icons.person_outlined),
              const SizedBox(height: 12),
              _buildField(
                'Apellido',
                _apellidoController,
                Icons.person_outlined,
              ),
              const SizedBox(height: 12),
              _buildField(
                'Email',
                _emailController,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
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
                                  _apellidoController.text.isEmpty ||
                                  _emailController.text.isEmpty ||
                                  _ciudadSeleccionada == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'CI, nombre, apellido, email y ciudad son requeridos',
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
                                  apellido: _apellidoController.text.trim(),
                                  email: _emailController.text.trim(),
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
