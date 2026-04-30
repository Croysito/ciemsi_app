import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_event.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_state.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';

class GenerarRecetaPage extends StatefulWidget {
  final CitaMedica cita;

  const GenerarRecetaPage({super.key, required this.cita});

  @override
  State<GenerarRecetaPage> createState() => _GenerarRecetaPageState();
}

class _GenerarRecetaPageState extends State<GenerarRecetaPage> {
  final _detalleController = TextEditingController();
  String? _whatsappLink;
  String? _pdfUrl;
  bool _recetaGenerada = false;

  @override
  void dispose() {
    _detalleController.dispose();
    super.dispose();
  }

  Future<void> _obtenerWhatsappLink() async {
    try {
      final response = await ApiClientProvider.instance.dio.get(
        '/recetas/cita/${widget.cita.id}/whatsapp',
      );
      setState(() {
        _whatsappLink = response.data['whatsappLink'];
        _pdfUrl = response.data['pdfUrl'];
      });
    } catch (e) {
      debugPrint('Error obteniendo link: $e');
    }
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
            setState(() => _recetaGenerada = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Receta generada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            _obtenerWhatsappLink();
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
                            widget.cita.paciente.ci,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Medicamentos
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

              if (!_recetaGenerada)
                BlocBuilder<TratamientoBloc, TratamientoState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: state is TratamientoLoading
                            ? null
                            : () {
                                if (_detalleController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Escribe los medicamentos'),
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
                        icon: state is TratamientoLoading
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

              if (_recetaGenerada && _whatsappLink != null) ...[
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
                          onPressed: () async {
                            final uri = Uri.parse(_whatsappLink!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text(
                            'Enviar por WhatsApp',
                            style: TextStyle(color: Colors.white),
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
