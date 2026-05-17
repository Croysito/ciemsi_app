import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_event.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_state.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/core/utils/receta_pdf_generator.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';

class GenerarRecetaPage extends StatefulWidget {
  final CitaMedica cita;
  const GenerarRecetaPage({super.key, required this.cita});

  @override
  State<GenerarRecetaPage> createState() => _GenerarRecetaPageState();
}

class _GenerarRecetaPageState extends State<GenerarRecetaPage> {
  final _detalleController = TextEditingController();
  File? _pdfFile;
  bool _recetaGenerada = false;
  bool _generandoPdf = false;

  @override
  void dispose() {
    _detalleController.dispose();
    super.dispose();
  }

  Future<void> _generarPdfLocal() async {
    setState(() => _generandoPdf = true);
    try {
      final file = await RecetaPdfGenerator.generar(
        cita: widget.cita,
        detalle: _detalleController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _pdfFile = file;
        _recetaGenerada = true;
        _generandoPdf = false;
      });
      _agregarAlHistorial();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receta generada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _generandoPdf = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _agregarAlHistorial() async {
    final fecha = DateFormat('dd/MM/yyyy').format(widget.cita.fecha);
    final detalle =
        'Receta médica\n'
        'Fecha: $fecha | Servicio: ${widget.cita.servicio.nombreServicio}\n\n'
        'Medicamentos prescritos:\n'
        '${_detalleController.text.trim()}';
    try {
      await ApiClientProvider.instance.dio.post(
        '/historial/${widget.cita.paciente.id}/notas',
        data: {'detalle': detalle},
      );
    } catch (e) {
      debugPrint('Historial: no se pudo registrar la receta - $e');
    }
  }

  Future<void> _compartir() async {
    if (_pdfFile == null) return;
    await Share.shareXFiles(
      [XFile(_pdfFile!.path)],
      subject: 'Receta Médica - ${widget.cita.paciente.nombreCompleto}',
      text: 'Receta médica emitida por CIEMSI',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Generar Receta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<TratamientoBloc, TratamientoState>(
        listener: (context, state) {
          if (state is RecetaGenerada) {
            _generarPdfLocal();
          }
          if (state is TratamientoError) {
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
              // Info paciente
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
                            widget.cita.paciente.nombreCompleto,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'CI: ${widget.cita.paciente.ci}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo medicamentos
              const Text(
                'Medicamentos a recetar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _detalleController,
                maxLines: 8,
                enabled: !_recetaGenerada,
                decoration: InputDecoration(
                  hintText:
                      'Escribe los medicamentos, dosis y frecuencia...\nEj: Amoxicilina 500mg - 1 cápsula cada 8 horas por 7 días',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Botón generar
              if (!_recetaGenerada)
                BlocBuilder<TratamientoBloc, TratamientoState>(
                  builder: (context, state) {
                    final loading =
                        state is TratamientoLoading || _generandoPdf;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: loading
                            ? null
                            : () {
                                if (_detalleController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Escribe los medicamentos',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                context.read<TratamientoBloc>().add(
                                  GenerarRecetaEvent(
                                    citaId: widget.cita.id,
                                    detalle: _detalleController.text.trim(),
                                  ),
                                );
                              },
                        icon: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.white,
                              ),
                        label: const Text(
                          'Generar Receta PDF',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B5C8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Estado exitoso + botón compartir
              if (_recetaGenerada) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Receta generada correctamente',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _compartir,
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text(
                            'Enviar por WhatsApp',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
