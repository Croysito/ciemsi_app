import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/core/services/google_auth_service.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/paciente.dart';
import '../../data/datasources/nota_borrador_local_datasource.dart';
import '../../domain/entities/nota_plantilla.dart';
import '../../domain/utils/comandos_voz_puntuacion.dart';
import '../bloc/historial_bloc.dart';
import '../bloc/historial_event.dart';
import '../bloc/historial_state.dart';
import '../controllers/nota_borrador_controller.dart';
import '../widgets/dictado_bar.dart';
import '../widgets/nota_adjunto_chip.dart';
import '../widgets/nota_seccion_editor.dart';
import '../widgets/nota_template_chips.dart';
import 'historial_page.dart';

/// P1 · Nota de evolución — dictado permanente + plantillas por secciones.
///
/// Reemplaza el campo de texto único de la versión anterior: la nota se
/// serializa a texto plano con encabezados (representación canónica que
/// sigue viajando tal cual a `POST /historial/:pacienteId/notas`, sin
/// cambios de backend); la estructura por secciones sólo vive en el
/// borrador local.
class AgregarNotaPage extends StatefulWidget {
  final Paciente paciente;
  const AgregarNotaPage({super.key, required this.paciente});

  @override
  State<AgregarNotaPage> createState() => _AgregarNotaPageState();
}

class _AgregarNotaPageState extends State<AgregarNotaPage>
    with WidgetsBindingObserver {
  NotaPlantilla _plantilla = NotaPlantilla.evolucion;
  Map<String, TextEditingController> _controllers = {};
  Map<String, FocusNode> _focusNodes = {};
  late final NotaBorradorController _borrador;

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _detencionManual = false;
  double _audioLevel = 0;
  String? _seccionDictando;
  String _ultimaSeccionEnfocada = '';
  String _textoBaseSesion = '';

  DateTime? _ultimoGuardado;
  bool _borradorRecienRestaurado = false;
  Timer? _restauradoTimer;

  final List<AdjuntoPendiente> _adjuntosPendientes = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _inicializarControllers(_plantilla);
    _ultimaSeccionEnfocada = _plantilla.secciones.first.id;
    _borrador = NotaBorradorController(pacienteId: widget.paciente.id)
      ..addListener(_onBorradorChanged);
    WidgetsBinding.instance.addObserver(this);
    _initSpeech();
    _cargarBorrador();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _guardarBorradorInmediato();
    _borrador.removeListener(_onBorradorChanged);
    _borrador.dispose();
    _restauradoTimer?.cancel();
    _disposeControllers();
    _speechToText.stop();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Secciones / plantilla
  // ---------------------------------------------------------------------

  void _inicializarControllers(NotaPlantilla plantilla, {Map<String, String>? valores}) {
    _controllers = {
      for (final s in plantilla.secciones)
        s.id: TextEditingController(text: valores?[s.id] ?? ''),
    };
    _focusNodes = {for (final s in plantilla.secciones) s.id: FocusNode()};
    for (final entry in _controllers.entries) {
      entry.value.addListener(() => _onSeccionCambiada(entry.key));
    }
    for (final entry in _focusNodes.entries) {
      entry.value.addListener(() {
        if (entry.value.hasFocus) _ultimaSeccionEnfocada = entry.key;
      });
    }
  }

  void _disposeControllers() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
  }

  Map<String, String> _valoresActuales() => {
    for (final entry in _controllers.entries) entry.key: entry.value.text,
  };

  void _onSeccionCambiada(String seccionId) {
    if (!mounted) return;
    setState(() {});
    _borrador.programarAutoguardado(
      NotaBorradorData(plantillaId: _plantilla.id, secciones: _valoresActuales()),
    );
  }

  void _cambiarPlantilla(NotaPlantilla nueva) {
    if (nueva.id == _plantilla.id) return;
    final valoresActuales = _valoresActuales();
    if (_plantilla.estaVacia(valoresActuales)) {
      _aplicarCambioPlantilla(nueva, nueva.migrarSecciones(valoresActuales));
    } else {
      _confirmarCambioPlantilla(nueva, valoresActuales);
    }
  }

  Future<void> _confirmarCambioPlantilla(
    NotaPlantilla nueva,
    Map<String, String> valoresActuales,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cambiar de plantilla?'),
        content: const Text(
          'El texto ya escrito no se pierde: se pasa a la primera sección de la nueva plantilla.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
            child: const Text('Cambiar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      _aplicarCambioPlantilla(nueva, nueva.migrarSecciones(valoresActuales));
    }
  }

  void _aplicarCambioPlantilla(NotaPlantilla nueva, Map<String, String> valoresNuevos) {
    setState(() {
      _disposeControllers();
      _plantilla = nueva;
      _inicializarControllers(nueva, valores: valoresNuevos);
      _ultimaSeccionEnfocada = nueva.secciones.first.id;
    });
    _borrador.programarAutoguardado(
      NotaBorradorData(plantillaId: nueva.id, secciones: valoresNuevos),
      inmediato: true,
    );
  }

  // ---------------------------------------------------------------------
  // Borrador / autoguardado
  // ---------------------------------------------------------------------

  Future<void> _cargarBorrador() async {
    final borrador = await _borrador.cargar();
    if (borrador == null || !mounted) return;
    final plantilla = NotaPlantilla.porId(borrador.plantillaId);
    setState(() {
      _disposeControllers();
      _plantilla = plantilla;
      _inicializarControllers(plantilla, valores: borrador.secciones);
      _ultimaSeccionEnfocada = plantilla.secciones.first.id;
      _ultimoGuardado = DateTime.now();
      _borradorRecienRestaurado = true;
    });
    _restauradoTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _borradorRecienRestaurado = false);
    });
  }

  void _onBorradorChanged() {
    if (!mounted) return;
    setState(() => _ultimoGuardado = DateTime.now());
  }

  void _guardarBorradorInmediato() {
    _borrador.programarAutoguardado(
      NotaBorradorData(plantillaId: _plantilla.id, secciones: _valoresActuales()),
      inmediato: true,
    );
  }

  void _deshacer() {
    final anterior = _borrador.deshacer();
    if (anterior == null) return;
    final plantilla = NotaPlantilla.porId(anterior.plantillaId);
    setState(() {
      _disposeControllers();
      _plantilla = plantilla;
      _inicializarControllers(plantilla, valores: anterior.secciones);
      _ultimaSeccionEnfocada = plantilla.secciones.first.id;
    });
  }

  Future<void> _confirmarDescartarBorrador() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Descartar borrador?'),
        content: const Text('Se perderá el contenido no guardado de esta nota.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmar == true) _descartarBorrador();
  }

  void _descartarBorrador() {
    _borrador.descartar();
    setState(() {
      _disposeControllers();
      _plantilla = NotaPlantilla.evolucion;
      _inicializarControllers(_plantilla);
      _ultimaSeccionEnfocada = _plantilla.secciones.first.id;
      _adjuntosPendientes.clear();
    });
  }

  void _verNotasAnteriores() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<HistorialBloc>(),
          child: HistorialPage(paciente: widget.paciente),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Dictado
  // ---------------------------------------------------------------------

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _audioLevel = 0;
        });
        _mostrarAvisoBreve('El dictado se detuvo. Nada de lo transcrito se perdió.');
      },
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && _isListening) {
          if (!mounted) return;
          final manual = _detencionManual;
          setState(() {
            _isListening = false;
            _audioLevel = 0;
          });
          _detencionManual = false;
          if (!manual) {
            _mostrarAvisoBreve('El dictado se detuvo. Nada de lo transcrito se perdió.');
          }
        }
      },
      debugLogging: false,
    );
    if (!mounted) return;
    setState(() {});
  }

  void _mostrarAvisoBreve(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 2)),
    );
  }

  String _resolverSeccionDictado() {
    for (final entry in _focusNodes.entries) {
      if (entry.value.hasFocus) return entry.key;
    }
    for (final seccion in _plantilla.secciones) {
      if ((_controllers[seccion.id]?.text ?? '').trim().isEmpty) return seccion.id;
    }
    if (_controllers.containsKey(_ultimaSeccionEnfocada)) return _ultimaSeccionEnfocada;
    return _plantilla.secciones.first.id;
  }

  Future<void> _iniciarDictado() async {
    if (!_speechEnabled) return;
    final seccionId = _resolverSeccionDictado();
    setState(() => _seccionDictando = seccionId);
    _textoBaseSesion = _controllers[seccionId]?.text ?? '';
    _focusNodes[seccionId]?.requestFocus();
    // Checkpoint inmediato: permite deshacer toda la sesión de dictado.
    _guardarBorradorInmediato();

    await _speechToText.listen(
      onResult: _onResultadoDictado,
      onSoundLevelChange: (level) {
        if (!mounted) return;
        setState(() => _audioLevel = _normalizarNivel(level));
      },
      localeId: 'es_ES',
      pauseFor: const Duration(seconds: 3),
    );
    if (!mounted) return;
    setState(() => _isListening = true);
  }

  double _normalizarNivel(double level) {
    // El rango real de `onSoundLevelChange` varía por plataforma y no está
    // documentado de forma estable: se normaliza con un clamp generoso en
    // vez de calibrar por dispositivo.
    return ((level + 2) / 12).clamp(0.0, 1.0);
  }

  void _onResultadoDictado(SpeechRecognitionResult result) {
    if (!mounted) return;
    final crudo = result.recognizedWords;

    if (ComandosVozPuntuacion.esComandoSiguiente(crudo)) {
      _saltarASiguienteSeccion();
      return;
    }

    final seccionId = _seccionDictando;
    final controller = seccionId != null ? _controllers[seccionId] : null;
    if (controller == null) return;

    final reconocido = ComandosVozPuntuacion.aplicar(crudo);
    final nuevoTexto = _textoBaseSesion.isEmpty
        ? reconocido
        : (reconocido.isEmpty ? _textoBaseSesion : '$_textoBaseSesion $reconocido');

    controller.text = nuevoTexto;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: nuevoTexto.length),
    );
  }

  void _saltarASiguienteSeccion() {
    final secciones = _plantilla.secciones;
    final idxActual = secciones.indexWhere((s) => s.id == _seccionDictando);
    if (idxActual == -1 || idxActual >= secciones.length - 1) return;
    final siguiente = secciones[idxActual + 1];
    setState(() => _seccionDictando = siguiente.id);
    _focusNodes[siguiente.id]?.requestFocus();
    _textoBaseSesion = _controllers[siguiente.id]?.text ?? '';
  }

  Future<void> _detenerDictado() async {
    _detencionManual = true;
    await _speechToText.stop();
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _audioLevel = 0;
    });
    _guardarBorradorInmediato();
  }

  void _toggleMic() {
    if (_isListening) {
      _detenerDictado();
    } else {
      _iniciarDictado();
    }
  }

  void _toggleTeclado() {
    final seccionId = _resolverSeccionDictado();
    FocusScope.of(context).requestFocus(_focusNodes[seccionId]);
  }

  String _labelSeccion(String? seccionId) {
    if (seccionId == null) return '';
    final seccion = _plantilla.secciones.where((s) => s.id == seccionId);
    if (seccion.isEmpty) return '';
    final etiqueta = seccion.first.etiqueta;
    return etiqueta.isEmpty ? _plantilla.nombre : etiqueta;
  }

  // ---------------------------------------------------------------------
  // Adjuntos (se suben recién después de guardar, cuando ya hay notaId)
  // ---------------------------------------------------------------------

  Future<void> _elegirAdjunto() async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.teal),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(ctx, 'imagen'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.teal),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(ctx, 'imagen'),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined, color: AppColors.teal),
              title: const Text('Archivo'),
              onTap: () => Navigator.pop(ctx, 'archivo'),
            ),
          ],
        ),
      ),
    );
    if (opcion == null) return;
    await _seleccionarArchivo(opcion);
  }

  Future<void> _seleccionarArchivo(String opcion) async {
    // No hay paquete de cámara en el proyecto (fuera de lo indicado en el
    // spec de P1) — "Tomar foto" y "Elegir de galería" comparten el
    // selector nativo de imágenes de file_picker.
    final result = opcion == 'archivo'
        ? await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: const ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'pdf'],
            withData: true,
          )
        : await FilePicker.platform.pickFiles(type: FileType.image, withData: true);

    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    final (tipo, mimeType) = _tipoYMimePorExtension(file.extension?.toLowerCase() ?? '');
    setState(() {
      _adjuntosPendientes.add(
        AdjuntoPendiente(
          nombre: file.name,
          mimeType: mimeType,
          bytes: file.bytes!.toList(),
          tipo: tipo,
        ),
      );
    });
  }

  (String, String) _tipoYMimePorExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return ('IMAGEN', 'image/jpeg');
      case 'png':
        return ('IMAGEN', 'image/png');
      case 'mp4':
        return ('VIDEO', 'video/mp4');
      case 'mov':
        return ('VIDEO', 'video/quicktime');
      case 'pdf':
        return ('DRIVE', 'application/pdf');
      default:
        return ('DRIVE', 'application/octet-stream');
    }
  }

  void _quitarAdjunto(int index) {
    setState(() => _adjuntosPendientes.removeAt(index));
  }

  Future<void> _subirAdjuntosPendientes(int notaId) async {
    if (_adjuntosPendientes.isEmpty || !mounted) return;
    final bloc = context.read<HistorialBloc>();

    String? tokens;
    try {
      tokens = await GoogleAuthService.obtenerTokens();
    } catch (_) {
      tokens = null;
    }
    // La nota ya quedó guardada aunque el usuario cancele el login de
    // Google o falle la subida: los adjuntos simplemente no se agregan.
    if (tokens == null) return;

    for (final adjunto in _adjuntosPendientes) {
      bloc.add(
        SubirArchivoDriveEvent(
          notaId: notaId,
          tipo: adjunto.tipo,
          tokens: tokens,
          bytes: adjunto.bytes,
          nombre: adjunto.nombre,
          mimeType: adjunto.mimeType,
        ),
      );
      await bloc.stream.firstWhere((s) => s is ArchivoSubido || s is HistorialError);
    }
  }

  // ---------------------------------------------------------------------
  // Guardar
  // ---------------------------------------------------------------------

  bool get _puedeGuardar => !_plantilla.estaVacia(_valoresActuales());

  Future<void> _guardar() async {
    if (!_puedeGuardar || _guardando) return;
    if (_isListening) await _detenerDictado();
    if (!mounted) return;

    final detalle = _plantilla.serializar(_valoresActuales());
    setState(() => _guardando = true);
    context.read<HistorialBloc>().add(
      AgregarNotaEvent(pacienteId: widget.paciente.id, detalle: detalle),
    );
  }

  Future<bool> _confirmarSalida() async {
    final hayCambios = !_plantilla.estaVacia(_valoresActuales());
    if (!hayCambios) return true;

    final accion = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tienes una nota sin guardar'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'seguir'),
            child: const Text('Seguir editando'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'descartar'),
            child: const Text('Descartar', style: TextStyle(color: AppColors.danger)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'guardar'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
            child: const Text('Guardar y salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (accion == 'guardar') {
      await _guardar();
      return false; // el propio guardado hace el pop al terminar
    }
    if (accion == 'descartar') {
      _descartarBorrador();
      return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final puedeSalir = await _confirmarSalida();
        if (puedeSalir && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: _buildAppBar(),
        body: BlocListener<HistorialBloc, HistorialState>(
          listener: _onHistorialState,
          child: Column(
            children: [
              const SizedBox(height: 12),
              NotaTemplateChips(seleccionada: _plantilla, onSeleccionar: _cambiarPlantilla),
              Expanded(
                child: NotaSeccionEditor(
                  plantilla: _plantilla,
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  adjuntos: _adjuntosPendientes,
                  onAdjuntar: _elegirAdjunto,
                  onQuitarAdjunto: _quitarAdjunto,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NotaBarraTrabajo(
          isRecording: _isListening,
          audioLevel: _audioLevel,
          seccionActivaLabel: _isListening ? _labelSeccion(_seccionDictando) : null,
          onToggleMic: _toggleMic,
          onToggleKeyboard: _toggleTeclado,
          micDisponible: _speechEnabled,
          guardarHabilitado: _puedeGuardar,
          guardando: _guardando,
          razonDeshabilitado: 'Escribe o dicta algo para guardar',
          onGuardar: _guardar,
        ),
      ),
    );
  }

  void _onHistorialState(BuildContext context, HistorialState state) {
    if (state is NotaAgregada) {
      _subirAdjuntosPendientes(state.nota.id).whenComplete(() {
        if (!mounted) return;
        _borrador.limpiarTrasGuardar();
        setState(() => _guardando = false);
        Navigator.pop(context, state.nota);
      });
    } else if (state is HistorialError && _guardando) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.mensaje),
          backgroundColor: AppColors.danger,
          action: SnackBarAction(label: 'Reintentar', onPressed: _guardar, textColor: Colors.white),
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    final etiquetaGuardado = _borradorRecienRestaurado ? 'Borrador recuperado' : 'Guardado automático';
    final subtitulo = _ultimoGuardado == null
        ? ''
        : '$etiquetaGuardado · ${DateFormat('HH:mm').format(_ultimoGuardado!)}';

    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        toolbarHeight: 64,
        backgroundColor: AppColors.teal,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nota · ${widget.paciente.nombreCompleto}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (subtitulo.isNotEmpty)
              Text(
                subtitulo,
                style: const TextStyle(fontSize: 11, color: Color(0xBFFFFFFF)),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _borrador.puedeDeshacer ? _deshacer : null,
            icon: const Icon(Icons.undo),
            tooltip: 'Deshacer',
            color: _borrador.puedeDeshacer ? Colors.white : Colors.white.withValues(alpha: 0.4),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'descartar') _confirmarDescartarBorrador();
              if (value == 'notas') _verNotasAnteriores();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'descartar', child: Text('Descartar borrador')),
              PopupMenuItem(value: 'notas', child: Text('Ver notas anteriores del paciente')),
            ],
          ),
        ],
      ),
    );
  }
}
