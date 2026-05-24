import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/asistentes/domain/entities/asistente.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_bloc.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_event.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_state.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class ModificarAsistentePage extends StatefulWidget {
  final Asistente asistente;
  const ModificarAsistentePage({super.key, required this.asistente});

  @override
  State<ModificarAsistentePage> createState() => _ModificarAsistentePageState();
}

class _ModificarAsistentePageState extends State<ModificarAsistentePage> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  Ciudad? _ciudadSeleccionada;
  List<Ciudad> _ciudades = [];

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.asistente.nombre;
    _apellidoController.text = widget.asistente.apellido;
    _emailController.text = widget.asistente.email;
    context.read<AsistenteBloc>().add(CargarCiudadesAsistenteEvent());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Modificar Asistente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<AsistenteBloc, AsistenteState>(
        listener: (context, state) {
          if (state is CiudadesAsistenteCargadas) {
            setState(() {
              _ciudades = state.ciudades;
              if (widget.asistente.ciudad != null) {
                try {
                  _ciudadSeleccionada = _ciudades.firstWhere(
                    (c) => c.id == widget.asistente.ciudad!.id,
                  );
                } catch (_) {
                  _ciudadSeleccionada = null;
                }
              }
            });
          }
          if (state is AsistenteModificado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Asistente actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is AsistenteError) {
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
            children: [
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

              BlocBuilder<AsistenteBloc, AsistenteState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is AsistenteLoading
                          ? null
                          : () {
                              if (_nombreController.text.isEmpty ||
                                  _apellidoController.text.isEmpty ||
                                  _emailController.text.isEmpty ||
                                  _ciudadSeleccionada == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Todos los campos son requeridos',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              context.read<AsistenteBloc>().add(
                                ModificarAsistenteEvent(
                                  id: widget.asistente.id,
                                  nombre: _nombreController.text.trim(),
                                  apellido: _apellidoController.text.trim(),
                                  email: _emailController.text.trim(),
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
                      child: state is AsistenteLoading
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
