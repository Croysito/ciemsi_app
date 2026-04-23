import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_bloc.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_event.dart';
import 'package:ciemsi_app/features/asistentes/presentation/bloc/asistente_state.dart';
import 'package:ciemsi_app/features/asistentes/domain/entities/asistente.dart';
import 'crear_asistente_page.dart';
import 'modificar_asistente_page.dart';

class AsistentesPage extends StatefulWidget {
  const AsistentesPage({super.key});

  @override
  State<AsistentesPage> createState() => _AsistentesPageState();
}

class _AsistentesPageState extends State<AsistentesPage> {
  @override
  void initState() {
    super.initState();
    context.read<AsistenteBloc>().add(ListarAsistentesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Asistentes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AsistenteBloc>().add(ListarAsistentesEvent()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8DC63F),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AsistenteBloc>(),
                child: const CrearAsistentePage(),
              ),
            ),
          );
          context.read<AsistenteBloc>().add(ListarAsistentesEvent());
        },
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: BlocBuilder<AsistenteBloc, AsistenteState>(
        builder: (context, state) {
          if (state is AsistenteLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }

          if (state is AsistenteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    state.mensaje,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AsistenteBloc>().add(
                      ListarAsistentesEvent(),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is AsistentesListados ||
              state is AsistenteModificado ||
              state is EstadoCambiado) {
            if (state is AsistenteModificado || state is EstadoCambiado) {
              context.read<AsistenteBloc>().add(ListarAsistentesEvent());
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
              );
            }

            final asistentes = (state as AsistentesListados).asistentes;

            if (asistentes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No hay asistentes registrados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: asistentes.length,
              itemBuilder: (context, index) {
                final asistente = asistentes[index];
                return _buildAsistenteCard(context, asistente);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAsistenteCard(BuildContext context, Asistente asistente) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: asistente.estado
              ? const Color(0xFF00B5C8)
              : Colors.grey,
          child: Text(
            asistente.nombre[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          asistente.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              asistente.email,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              asistente.ciudad?.nombreCiudad ?? 'Sin ciudad',
              style: const TextStyle(color: Color(0xFF00B5C8), fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Switch activo/inactivo
            Switch(
              value: asistente.estado,
              activeColor: const Color(0xFF8DC63F),
              onChanged: (value) {
                context.read<AsistenteBloc>().add(
                  CambiarEstadoAsistenteEvent(id: asistente.id, estado: value),
                );
              },
            ),
            // Botón editar
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF00B5C8)),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AsistenteBloc>(),
                      child: ModificarAsistentePage(asistente: asistente),
                    ),
                  ),
                );
                context.read<AsistenteBloc>().add(ListarAsistentesEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
