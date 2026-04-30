import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_event.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_state.dart';
import 'crear_tratamiento_page.dart';

class TratamientosPage extends StatefulWidget {
  const TratamientosPage({super.key});

  @override
  State<TratamientosPage> createState() => _TratamientosPageState();
}

class _TratamientosPageState extends State<TratamientosPage> {
  @override
  void initState() {
    super.initState();
    context.read<TratamientoBloc>().add(ListarTratamientosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Tratamientos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<TratamientoBloc>().add(ListarTratamientosEvent()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8DC63F),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<TratamientoBloc>(),
                child: const CrearTratamientoPage(),
              ),
            ),
          );
          context.read<TratamientoBloc>().add(ListarTratamientosEvent());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<TratamientoBloc, TratamientoState>(
        builder: (context, state) {
          if (state is TratamientoLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          if (state is TratamientoCreado || state is TratamientoInitial) {
            context.read<TratamientoBloc>().add(ListarTratamientosEvent());
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          if (state is TratamientosListados) {
            if (state.tratamientos.isEmpty) {
              return const Center(
                child: Text(
                  'No hay tratamientos registrados',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tratamientos.length,
              itemBuilder: (context, index) {
                final t = state.tratamientos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: const Color(
                        0xFF00B5C8,
                      ).withOpacity(0.15),
                      child: const Icon(
                        Icons.healing_outlined,
                        color: Color(0xFF00B5C8),
                      ),
                    ),
                    title: Text(
                      t.nombreTratamiento,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (t.detalle != null)
                          Text(
                            t.detalle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        Text(
                          'Bs ${t.precioBase.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF8DC63F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          if (state is TratamientoError) {
            return Center(child: Text(state.mensaje));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
