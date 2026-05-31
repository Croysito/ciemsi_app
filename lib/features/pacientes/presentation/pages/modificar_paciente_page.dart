import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/paciente.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_bloc.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_event.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_state.dart';
import 'package:ciemsi_app/core/utils/date_input_formatter.dart';

class ModificarPacientePage extends StatefulWidget {
  final Paciente paciente;
  const ModificarPacientePage({super.key, required this.paciente});

  @override
  State<ModificarPacientePage> createState() => _ModificarPacientePageState();
}

class _ModificarPacientePageState extends State<ModificarPacientePage> {
  final _ciController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  Ciudad? _ciudadSeleccionada;
  List<Ciudad> _ciudades = [];
  String? _generoSeleccionado;

  @override
  void initState() {
    super.initState();
    _ciController.text = widget.paciente.ci;
    _nombreController.text = widget.paciente.usuario.nombre;
    _apellidoController.text = widget.paciente.usuario.apellido;
    _emailController.text = widget.paciente.usuario.email;
    _telefonoController.text = widget.paciente.telefono ?? '';
    if (widget.paciente.fechaNacimiento != null) {
      _fechaNacimientoController.text = formatFecha(
        widget.paciente.fechaNacimiento!,
      );
    }
    _generoSeleccionado = widget.paciente.genero;
    context.read<PacienteBloc>().add(CargarCiudadesEvent());
  }

  @override
  void dispose() {
    _ciController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
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
              _buildField('CI', _ciController, Icons.badge_outlined),
              const SizedBox(height: 12),
              _buildField(
                'Teléfono',
                _telefonoController,
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fechaNacimientoController,
                keyboardType: TextInputType.number,
                inputFormatters: [DateInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  hintText: 'dd/mm/aaaa',
                  labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
                  prefixIcon: const Icon(
                    Icons.calendar_today_outlined,
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

              // Género
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wc_outlined, color: Color(0xFF00B5C8), size: 20),
                    const SizedBox(width: 12),
                    const Text('Género', style: TextStyle(color: Color(0xFF00B5C8))),
                    const Spacer(),
                    _buildGeneroOption('M', 'Masculino'),
                    const SizedBox(width: 8),
                    _buildGeneroOption('F', 'Femenino'),
                  ],
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
                                  _nombreController.text.isEmpty ||
                                  _ciudadSeleccionada == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Nombre, CI y ciudad son requeridos',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              final fechaNac = parseFechaNacimiento(
                                _fechaNacimientoController.text,
                              );
                              if (_fechaNacimientoController.text.isNotEmpty &&
                                  fechaNac == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Fecha inválida. Use el formato dd/mm/aaaa',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              context.read<PacienteBloc>().add(
                                ModificarPacienteEvent(
                                  id: widget.paciente.id,
                                  ci: _ciController.text.trim(),
                                  nombre: _nombreController.text.trim(),
                                  apellido: _apellidoController.text.trim(),
                                  email: _emailController.text.trim(),
                                  telefono: _telefonoController.text.trim(),
                                  fechaNacimiento: fechaNac,
                                  genero: _generoSeleccionado,
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

  Widget _buildGeneroOption(String valor, String etiqueta) {
    final seleccionado = _generoSeleccionado == valor;
    return GestureDetector(
      onTap: () => setState(() => _generoSeleccionado = seleccionado ? null : valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF00B5C8) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? const Color(0xFF00B5C8) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          etiqueta,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: seleccionado ? Colors.white : Colors.black54,
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
