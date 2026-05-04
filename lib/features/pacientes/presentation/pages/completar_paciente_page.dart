import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/paciente.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_bloc.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_event.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_state.dart';

class CompletarPacientePage extends StatefulWidget {
  final Paciente paciente;
  /// Callback que se ejecuta tras guardar exitosamente
  final VoidCallback? onCompletado;

  const CompletarPacientePage({
    super.key,
    required this.paciente,
    this.onCompletado,
  });

  @override
  State<CompletarPacientePage> createState() => _CompletarPacientePageState();
}

class _CompletarPacientePageState extends State<CompletarPacientePage> {
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
    // Pre-llenar nombre y teléfono que ya se tenían
    _nombreController.text = widget.paciente.usuario.nombre;
    _telefonoController.text = widget.paciente.telefono ?? '';
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
      locale: const Locale('es', 'ES'),
      initialDate: DateTime(1990),
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

  void _guardar() {
    if (_ciController.text.isEmpty ||
        _nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _ciudadSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CI, nombre, apellido, email y ciudad son requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<PacienteBloc>().add(
      CompletarPacienteEvent(
        id: widget.paciente.id,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Completar Datos del Paciente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        // No permite volver sin completar
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<PacienteBloc, PacienteState>(
        listener: (context, state) {
          if (state is CiudadesCargadas) {
            setState(() => _ciudades = state.ciudades);
          }
          if (state is PacienteCompletado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Datos completados correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            widget.onCompletado?.call();
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
              // Banner informativo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B5C8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00B5C8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF00B5C8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'El paciente "${widget.paciente.usuario.nombre}" fue registrado provisionalmente. '
                        'Por favor completa sus datos para continuar con la cita.',
                        style: const TextStyle(
                          color: Color(0xFF00B5C8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Datos personales',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),

              _buildField('Nombre *', _nombreController, Icons.person_outlined),
              const SizedBox(height: 12),
              _buildField('Apellido *', _apellidoController, Icons.person_outlined),
              const SizedBox(height: 12),
              _buildField(
                'CI *',
                _ciController,
                Icons.badge_outlined,
                hint: 'Cédula de identidad',
              ),
              const SizedBox(height: 12),
              _buildField(
                'Email *',
                _emailController,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                hint: 'Se usará para iniciar sesión',
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

              // Fecha de nacimiento
              GestureDetector(
                onTap: _seleccionarFecha,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF00B5C8)),
                      const SizedBox(width: 12),
                      Text(
                        _fechaNacimiento != null
                            ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!)
                            : 'Fecha de nacimiento',
                        style: TextStyle(
                          color: _fechaNacimiento != null ? Colors.black : Colors.grey,
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
                    hint: const Text('Seleccionar ciudad *'),
                    value: _ciudadSeleccionada,
                    items: _ciudades
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.nombreCiudad),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _ciudadSeleccionada = value),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nota sobre contraseña
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8DC63F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8DC63F)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_outline, color: Color(0xFF8DC63F), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'La contraseña del paciente será su CI',
                        style: TextStyle(
                          color: Color(0xFF8DC63F),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
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
                      onPressed: state is PacienteLoading ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B5C8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state is PacienteLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Guardar y Continuar',
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
    String? hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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