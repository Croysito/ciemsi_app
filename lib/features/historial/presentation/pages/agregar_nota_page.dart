import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../domain/utils/comandos_voz_puntuacion.dart';
import '../bloc/historial_bloc.dart';
import '../bloc/historial_event.dart';
import '../bloc/historial_state.dart';
import '../controllers/nota_borrador_controller.dart';

class AgregarNotaPage extends StatefulWidget {
  final int pacienteId;
  const AgregarNotaPage({super.key, required this.pacienteId});

  @override
  State<AgregarNotaPage> createState() => _AgregarNotaPageState();
}

class _AgregarNotaPageState extends State<AgregarNotaPage>
    with WidgetsBindingObserver {
  final _detalleController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  late final NotaBorradorController _borrador;

  bool _speechEnabled = false;
  bool _isListening = false;
  String _textoBaseSesion = '';

  @override
  void initState() {
    super.initState();
    _borrador = NotaBorradorController(pacienteId: widget.pacienteId)
      ..addListener(_onBorradorChanged);
    WidgetsBinding.instance.addObserver(this);
    _initSpeech();
    _cargarBorrador();
  }

  void _onBorradorChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _cargarBorrador() async {
    final borrador = await _borrador.cargar();
    if (borrador == null || !mounted) return;
    setState(() {
      _detalleController.text = borrador;
      _detalleController.selection = TextSelection.fromPosition(
        TextPosition(offset: borrador.length),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _borrador.programarAutoguardado(_detalleController.text, inmediato: true);
    }
  }

  void _deshacer() {
    final anterior = _borrador.deshacer();
    if (anterior == null) return;
    setState(() {
      _detalleController.text = anterior;
      _detalleController.selection = TextSelection.fromPosition(
        TextPosition(offset: anterior.length),
      );
    });
  }

  void _descartarBorrador() {
    _borrador.descartar();
    setState(() => _detalleController.clear());
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
    // Checkpoint inmediato: permite deshacer toda la sesión de dictado.
    _borrador.programarAutoguardado(_detalleController.text, inmediato: true);
    // Texto base sobre el que se reconstruye cada actualización de esta
    // sesión: el paquete reporta resultados parciales acumulados (no
    // incrementales), así que hay que REEMPLAZAR, no concatenar en cada
    // callback, o el texto termina duplicado/triplicado.
    _textoBaseSesion = _detalleController.text;
    await _speechToText.listen(
      onResult: (result) {
        if (!mounted) return;
        final reconocido = ComandosVozPuntuacion.aplicar(
          result.recognizedWords,
        );
        final nuevoTexto = _textoBaseSesion.isEmpty
            ? reconocido
            : (reconocido.isEmpty
                  ? _textoBaseSesion
                  : '$_textoBaseSesion $reconocido');
        setState(() {
          _detalleController.text = nuevoTexto;
          // Mueve el cursor al final
          _detalleController.selection = TextSelection.fromPosition(
            TextPosition(offset: _detalleController.text.length),
          );
        });
        _borrador.programarAutoguardado(nuevoTexto);
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
    _borrador.programarAutoguardado(_detalleController.text, inmediato: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _borrador.programarAutoguardado(_detalleController.text, inmediato: true);
    _borrador.removeListener(_onBorradorChanged);
    _borrador.dispose();
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
        actions: [
          IconButton(
            onPressed: _borrador.puedeDeshacer ? _deshacer : null,
            icon: const Icon(Icons.undo),
            tooltip: 'Deshacer',
            color: _borrador.puedeDeshacer
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
          ),
        ],
      ),
      body: BlocListener<HistorialBloc, HistorialState>(
        listener: (context, state) {
          if (state is NotaAgregada) {
            _borrador.limpiarTrasGuardar();
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
              // Aviso de borrador restaurado
              if (_borrador.hayBorradorRestaurado)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Se restauró una nota sin guardar',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _descartarBorrador,
                        child: const Text('Descartar'),
                      ),
                    ],
                  ),
                ),

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
                      onChanged: (texto) =>
                          _borrador.programarAutoguardado(texto),
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
