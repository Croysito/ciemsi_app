import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/nota_evolucion.dart';
import '../bloc/historial_bloc.dart';
import '../bloc/historial_event.dart';
import '../bloc/historial_state.dart';

/// Edición de una nota de evolución ya guardada.
///
/// La nota vive en el backend como texto plano con encabezados (ver
/// `AgregarNotaPage`); acá se edita ese texto plano directamente, sin pasar
/// por el editor de secciones/dictado que se usa al crear una nota nueva.
class EditarNotaPage extends StatefulWidget {
  final NotaEvolucion nota;
  const EditarNotaPage({super.key, required this.nota});

  @override
  State<EditarNotaPage> createState() => _EditarNotaPageState();
}

class _EditarNotaPageState extends State<EditarNotaPage> {
  late final TextEditingController _controller;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.nota.detalle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _guardar() {
    final detalle = _controller.text.trim();
    if (detalle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La nota no puede quedar vacía')),
      );
      return;
    }
    setState(() => _guardando = true);
    context.read<HistorialBloc>().add(
      ActualizarNotaEvent(notaId: widget.nota.id, detalle: detalle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Editar Nota',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<HistorialBloc, HistorialState>(
        listener: (context, state) {
          if (state is NotaActualizada) {
            Navigator.pop(context, state.nota);
          }
          if (state is HistorialError) {
            setState(() => _guardando = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B5C8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar cambios',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
