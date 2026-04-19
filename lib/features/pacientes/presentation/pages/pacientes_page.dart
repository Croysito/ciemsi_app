import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/paciente_bloc.dart';
import '../bloc/paciente_event.dart';
import '../bloc/paciente_state.dart';
import 'registrar_paciente_page.dart';
import 'detalle_paciente_page.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  final _searchController = TextEditingController();
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    context.read<PacienteBloc>().add(ListarPacientesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Pacientes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<PacienteBloc>().add(ListarPacientesEvent()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8DC63F),
        onPressed: () async {
          final registrado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<PacienteBloc>(),
                child: const RegistrarPacientePage(),
              ),
            ),
          );
          if (registrado == true) {
            context.read<PacienteBloc>().add(ListarPacientesEvent());
          }
        },
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o CI...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00B5C8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _busqueda = value),
            ),
          ),

          // Lista
          Expanded(
            child: BlocBuilder<PacienteBloc, PacienteState>(
              builder: (context, state) {
                if (state is PacienteLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
                  );
                }

                if (state is PacienteError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.mensaje,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<PacienteBloc>().add(
                            ListarPacientesEvent(),
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PacientesListados) {
                  final pacientes = state.pacientes
                      .where(
                        (p) =>
                            p.nombre.toLowerCase().contains(
                              _busqueda.toLowerCase(),
                            ) ||
                            p.ci.toLowerCase().contains(
                              _busqueda.toLowerCase(),
                            ),
                      )
                      .toList();

                  if (pacientes.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'No se encontraron pacientes',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pacientes.length,
                    itemBuilder: (context, index) {
                      final paciente = pacientes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF00B5C8),
                            child: Text(
                              paciente.nombre[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            paciente.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'CI: ${paciente.ci} • ${paciente.ciudad.nombreCiudad}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF00B5C8),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<PacienteBloc>(),
                                  child: DetallePacientePage(
                                    paciente: paciente,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
