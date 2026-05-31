import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../pacientes/domain/entities/paciente.dart';
import '../bloc/historial_bloc.dart';
import '../bloc/historial_event.dart';
import '../bloc/historial_state.dart';
import '../../domain/entities/nota_evolucion.dart';
import 'agregar_nota_page.dart';
import 'nota_detalle_page.dart';
import '../widgets/bold_markdown_text.dart';

class HistorialPage extends StatefulWidget {
  final Paciente paciente;
  const HistorialPage({super.key, required this.paciente});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistorialBloc>().add(
      ObtenerHistorialEvent(widget.paciente.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          'Historial - ${widget.paciente.nombreCompleto}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8DC63F),
        onPressed: () async {
          final agregada = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<HistorialBloc>(),
                child: AgregarNotaPage(pacienteId: widget.paciente.id),
              ),
            ),
          );
          if (agregada == true) {
            context.read<HistorialBloc>().add(
              ObtenerHistorialEvent(widget.paciente.id),
            );
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agregar Nota',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocBuilder<HistorialBloc, HistorialState>(
        builder: (context, state) {
          if (state is HistorialLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }

          if (state is HistorialError) {
            return Center(child: Text(state.mensaje));
          }

          if (state is HistorialObtenido) {
            final notas = state.historial.notas;

            if (notas.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No hay notas en el historial',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notas.length,
              itemBuilder: (context, index) {
                final nota = notas[index];
                return _buildNotaCard(context, nota);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildNotaCard(BuildContext context, NotaEvolucion nota) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final actualizado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<HistorialBloc>(),
                child: NotaDetallePage(nota: nota),
              ),
            ),
          );
          if (actualizado == true) {
            context.read<HistorialBloc>().add(
              ObtenerHistorialEvent(widget.paciente.id),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Color(0xFF00B5C8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd/MM/yyyy').format(nota.fecha),
                    style: const TextStyle(
                      color: Color(0xFF00B5C8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (nota.links.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8DC63F).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            size: 14,
                            color: Color(0xFF8DC63F),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${nota.links.length}',
                            style: const TextStyle(
                              color: Color(0xFF8DC63F),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              BoldMarkdownText(
                nota.detalle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver detalle',
                    style: TextStyle(color: Color(0xFF00B5C8), fontSize: 12),
                  ),
                  Icon(Icons.chevron_right, color: Color(0xFF00B5C8), size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
