import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../bloc/historial_bloc.dart';
import '../bloc/historial_event.dart';
import '../bloc/historial_state.dart';

class AgregarNotaPage extends StatefulWidget {
  final int pacienteId;
  const AgregarNotaPage({super.key, required this.pacienteId});

  @override
  State<AgregarNotaPage> createState() => _AgregarNotaPageState();
}

class _AgregarNotaPageState extends State<AgregarNotaPage> {
  final _detalleController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        debugPrint('Speech error: ${error.errorMsg}');
        if (!mounted) return;
        setState(() => _isListening = false);
      },
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          if (!mounted) return;
          setState(() => _isListening = false);
        }
      },
      debugLogging: false,
    );
    debugPrint('Speech enabled: $_speechEnabled');
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startListening() async {
    await _speechToText.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _lastWords = result.recognizedWords;
          // Agrega el texto dictado al campo existente
          final textoActual = _detalleController.text;
          if (textoActual.isEmpty) {
            _detalleController.text = _lastWords;
          } else {
            _detalleController.text = '$textoActual $_lastWords';
          }
          // Mueve el cursor al final
          _detalleController.selection = TextSelection.fromPosition(
            TextPosition(offset: _detalleController.text.length),
          );
        });
      },
      localeId: 'es_ES', // Español
      pauseFor: const Duration(seconds: 3),
    );
    if (!mounted) return;
    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _detalleController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Agregar Nota',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<HistorialBloc, HistorialState>(
        listener: (context, state) {
          if (state is NotaAgregada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nota agregada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is HistorialError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Indicador de escucha
              if (_isListening)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B5C8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00B5C8)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic, color: Color(0xFF00B5C8), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Escuchando... habla ahora',
                        style: TextStyle(
                          color: Color(0xFF00B5C8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Campo de texto
              Expanded(
                child: Stack(
                  children: [
                    TextField(
                      controller: _detalleController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Escribe o dicta la nota de evolución...',
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
                        contentPadding: const EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          60,
                        ),
                      ),
                    ),

                    // Botón micrófono flotante dentro del campo
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: _speechEnabled
                          ? GestureDetector(
                              onTap: _isListening
                                  ? _stopListening
                                  : _startListening,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isListening
                                      ? Colors.red
                                      : const Color(0xFF00B5C8),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (_isListening
                                                  ? Colors.red
                                                  : const Color(0xFF00B5C8))
                                              .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isListening ? Icons.stop : Icons.mic,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            )
                          : const Tooltip(
                              message: 'Micrófono no disponible',
                              child: Icon(Icons.mic_off, color: Colors.grey),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botón guardar
              BlocBuilder<HistorialBloc, HistorialState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is HistorialLoading
                          ? null
                          : () {
                              if (_detalleController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'La nota no puede estar vacía',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              // Detener escucha si está activa
                              if (_isListening) _stopListening();
                              context.read<HistorialBloc>().add(
                                AgregarNotaEvent(
                                  pacienteId: widget.pacienteId,
                                  detalle: _detalleController.text.trim(),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DC63F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state is HistorialLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Guardar Nota',
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
}
