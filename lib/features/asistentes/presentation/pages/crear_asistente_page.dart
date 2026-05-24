import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_bloc.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_event.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_state.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class CrearAsistentePage extends StatefulWidget {
  const CrearAsistentePage({super.key});

  @override
  State<CrearAsistentePage> createState() => _CrearAsistentePageState();
}

class _CrearAsistentePageState extends State<CrearAsistentePage> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _ciController = TextEditingController();
  Ciudad? _ciudadSeleccionada;
  List<Ciudad> _ciudades = [];

  @override
  void initState() {
    super.initState();
    context.read<AsistenteBloc>().add(CargarCiudadesAsistenteEvent());
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
            Text('Asistente Creado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparte estas credenciales con el asistente:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildCredencial('Email', email),
            const SizedBox(height: 8),
            _buildCredencial('Contraseña', password),
            const SizedBox(height: 12),
            const Text(
              '⚠️ La contraseña es el CI del asistente.',
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
              Navigator.pop(context);
              Navigator.pop(context, true);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _ciController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Crear Asistente',
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
            });
          }
          if (state is AsistenteCreado) {
            _mostrarCredenciales(state.email, state.password);
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              _buildField('CI', _ciController, Icons.badge_outlined),
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
                                  _ciController.text.isEmpty ||
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
                                CrearAsistenteEvent(
                                  nombre: _nombreController.text.trim(),
                                  apellido: _apellidoController.text.trim(),
                                  email: _emailController.text.trim(),
                                  ci: _ciController.text.trim(),
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
                              'Crear Asistente',
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
