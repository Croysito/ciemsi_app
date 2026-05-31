import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/asistente_bloc.dart';
import '../bloc/asistente_event.dart';
import '../bloc/asistente_state.dart';

enum _RespuestaTipo { texto, multiple, unica, escala, frecuencia, zonaCuerpo }

class _PreguntaClinica {
  final String modulo;
  final String pregunta;
  final _RespuestaTipo tipo;
  final List<String> opciones;
  final String? ayuda;
  final IconData icono;

  const _PreguntaClinica({
    required this.modulo,
    required this.pregunta,
    required this.tipo,
    this.opciones = const [],
    this.ayuda,
    this.icono = Icons.medical_information_outlined,
  });
}

class AsistenteChatPage extends StatefulWidget {
  const AsistenteChatPage({super.key});

  @override
  State<AsistenteChatPage> createState() => _AsistenteChatPageState();
}

class _AsistenteChatPageState extends State<AsistenteChatPage> {
  final _controller = TextEditingController();
  final _respuestaController = TextEditingController();
  final _scrollController = ScrollController();

  int _preguntaActual = 0;
  double _valorEscala = 5;
  bool _flujoCompletado = false;
  bool _debeScrollChat = false;
  bool _saludoEnviado = false;
  bool _mostrarFormulario = false;
  bool? _esNuevo; // null = cargando
  final Set<int> _indicesSaltados = {};
  final List<String> _respuestasAcumuladas = [];
  final List<String> _resumenRespuestas = [];
  final Set<String> _seleccionMultiple = {};
  bool _borradorRestaurado = false;
  bool _perfilPrecargado = false;

  static const _borradorPreguntaKey = 'asistente_borrador_pregunta';
  static const _borradorCompletadoKey = 'asistente_borrador_completado';
  static const _borradorPendientesKey = 'asistente_borrador_pendientes';
  static const _borradorResumenKey = 'asistente_borrador_resumen';

  // TTS
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _textoReproduciendo;
  int _ttsVersion = 0;

  static const _frecuencias = ['Nunca', '1-2/semana', '3-5/semana', 'Diario'];

  static const _zonasCuerpo = [
    'Cabeza',
    'Pecho',
    'Abdomen',
    'Espalda',
    'Pelvis',
    'Brazo/mano',
    'Pierna/pie',
    'Todo el cuerpo',
  ];

  static const _preguntas = [
    _PreguntaClinica(
      modulo: 'Identificacion',
      pregunta: 'Nombre completo',
      tipo: _RespuestaTipo.texto,
      icono: Icons.badge_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Identificacion',
      pregunta: 'Edad',
      tipo: _RespuestaTipo.unica,
      opciones: ['Menos de 18', '18 a 29', '30 a 44', '45 a 59', '60 o mas'],
      icono: Icons.cake_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Identificacion',
      pregunta: 'Fecha de nacimiento',
      tipo: _RespuestaTipo.texto,
      ayuda: 'Puedes escribirla como dia/mes/anio.',
      icono: Icons.event_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Identificacion',
      pregunta: 'Lugar de nacimiento',
      tipo: _RespuestaTipo.texto,
      icono: Icons.place_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Identificacion',
      pregunta: 'Lugares donde ha vivido',
      tipo: _RespuestaTipo.texto,
      ayuda: 'Incluye ciudad o zona y tiempo aproximado si lo recuerdas.',
      icono: Icons.map_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Identificacion',
      pregunta: 'Numero de celular',
      tipo: _RespuestaTipo.texto,
      icono: Icons.phone_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Identificacion',
      pregunta: 'Contacto de tutor o persona de confianza',
      tipo: _RespuestaTipo.texto,
      icono: Icons.contact_phone_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Semiologia actual',
      pregunta:
          'Cual es el principal problema o sintoma por el que busca ayuda hoy?',
      tipo: _RespuestaTipo.texto,
      icono: Icons.help_outline,
    ),
    _PreguntaClinica(
      modulo: 'Semiologia actual',
      pregunta: 'Desde cuando comenzo?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Hoy',
        'Hace unos dias',
        'Hace semanas',
        'Hace meses',
        'Hace anos',
        'No recuerdo',
      ],
      icono: Icons.schedule_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Semiologia actual',
      pregunta: 'Donde siente el problema?',
      tipo: _RespuestaTipo.zonaCuerpo,
      icono: Icons.accessibility_new_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Semiologia actual',
      pregunta: 'Que intensidad tiene de 0 a 10?',
      tipo: _RespuestaTipo.escala,
      ayuda: '0 es sin molestia y 10 es la mayor intensidad imaginable.',
      icono: Icons.speed_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Semiologia actual',
      pregunta: 'Que empeora el sintoma?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Movimiento',
        'Comer',
        'Ayuno',
        'Estres',
        'Frio',
        'Calor',
        'Noche',
        'Trabajo',
        'Ejercicio',
        'Nada claro',
        'Otro',
      ],
      icono: Icons.trending_up_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Semiologia actual',
      pregunta: 'Que mejora el sintoma?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Reposo',
        'Dormir',
        'Comer',
        'Tomar agua',
        'Calor local',
        'Frio local',
        'Medicamento',
        'Respirar/relajarse',
        'Nada claro',
        'Otro',
      ],
      icono: Icons.trending_down_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Semiologia actual',
      pregunta: 'Que otros sintomas acompanan?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Dolor',
        'Fatiga',
        'Mareos',
        'Ansiedad',
        'Insomnio',
        'Nauseas',
        'Falta de aire',
        'Palpitaciones',
        'Hormigueos',
        'Inflamacion',
        'Debilidad',
        'Fiebre',
        'Ninguno',
        'Otros',
      ],
      icono: Icons.checklist_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Semiologia actual',
      pregunta: 'Que cree usted que le esta enfermando?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Alimentacion',
        'Estres',
        'Trabajo',
        'Familia',
        'Infeccion',
        'Clima/ambiente',
        'Medicamentos',
        'Emociones',
        'No sabe',
        'Otro',
      ],
      ayuda: 'Puede ser algo fisico, emocional, laboral, familiar o ambiental.',
      icono: Icons.psychology_alt_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Exposicion laboral y ambiental',
      pregunta: 'En sus trabajos estuvo expuesto a:',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Alzar mucho peso',
        'Radiacion',
        'Quimicos',
        'Fumigacion',
        'Frio extremo',
        'Calor extremo',
        'Cambios de temperatura',
        'Ruidos continuos o intensos',
        'Polvos',
        'Humedad',
        'Sedentarismo',
        'Agua contaminada',
        'Golpes',
        'Ninguno',
      ],
      icono: Icons.factory_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Antecedentes medicos',
      pregunta: 'De que le operaron?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'No me operaron',
        'Apendice',
        'Vesicula',
        'Cesarea',
        'Hernia',
        'Amigdalas',
        'Traumatologia',
        'Otra',
      ],
      icono: Icons.local_hospital_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Antecedentes medicos',
      pregunta: 'Que enfermedades le diagnosticaron antes?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Presion alta',
        'Diabetes',
        'Trigliceridos o colesterol elevados',
        'Sobrepeso u obesidad',
        'Desnutricion',
        'Tuberculosis',
        'Neumonia',
        'Gastritis',
        'Hipotiroidismo',
        'Asma',
        'Enfermedad renal',
        'Higado graso',
        'Ansiedad o depresion',
        'Ninguna',
        'Otra',
      ],
      icono: Icons.assignment_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Antecedentes medicos',
      pregunta: 'Que tratamiento realizo y por cuanto tiempo?',
      tipo: _RespuestaTipo.texto,
      icono: Icons.healing_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Antecedentes medicos',
      pregunta: 'Que medicamentos toma actualmente?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Ninguno',
        'Presion',
        'Diabetes',
        'Dolor',
        'Antibiotico',
        'Antialergico',
        'Anticonceptivo',
        'Vitaminas/suplementos',
        'Otro',
      ],
      icono: Icons.medication_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Antecedentes medicos',
      pregunta: 'Recibio transfusion de sangre?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Si', 'No', 'No recuerdo'],
      icono: Icons.bloodtype_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Antecedentes medicos',
      pregunta: 'A que tiene alergias?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Ninguna conocida',
        'Medicamentos',
        'Alimentos',
        'Polvo',
        'Polen',
        'Animales',
        'Latex',
        'Otro',
      ],
      icono: Icons.warning_amber_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Fisiologia y homeostasis',
      pregunta: 'Ayer, cuantas veces orino?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Menos de 3', '3 a 5', '6 a 8', 'Mas de 8'],
      icono: Icons.water_drop_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Fisiologia y homeostasis',
      pregunta: 'Evacuaciones',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Menos de 1 vez por dia',
        '1 vez por dia',
        '2 a 4 veces por dia',
        'Mas de 5 veces por dia',
      ],
      icono: Icons.monitor_heart_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Fisiologia y homeostasis',
      pregunta: 'Ayer, aproximadamente cuanta agua tomo?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Menos de 500 ml',
        '500 ml a 1 litro',
        '1 a 2 litros',
        'Mas de 2 litros',
      ],
      icono: Icons.local_drink_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Fisiologia y homeostasis',
      pregunta: 'A que hora duerme?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Antes de 21:00',
        '21:00 a 22:00',
        '22:00 a 23:00',
        '23:00 a 00:00',
        'Despues de medianoche',
        'Variable',
      ],
      icono: Icons.bedtime_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Fisiologia y homeostasis',
      pregunta: 'A que hora despierta?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Antes de 5:00',
        '5:00 a 6:00',
        '6:00 a 7:00',
        '7:00 a 8:00',
        'Despues de 8:00',
        'Variable',
      ],
      icono: Icons.wb_sunny_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Fisiologia y homeostasis',
      pregunta: 'Se levanta frecuentemente por la noche?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Nunca', '1 vez', '2 a 3 veces', 'Mas de 4 veces'],
      icono: Icons.nightlight_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Nutricion inteligente',
      pregunta: 'Con que frecuencia consume alimentos inflamatorios?',
      tipo: _RespuestaTipo.frecuencia,
      icono: Icons.restaurant_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Nutricion inteligente',
      pregunta: 'Con que frecuencia consume ultraprocesados?',
      tipo: _RespuestaTipo.frecuencia,
      icono: Icons.fastfood_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Nutricion inteligente',
      pregunta: 'Con que frecuencia consume estimulantes?',
      tipo: _RespuestaTipo.frecuencia,
      ayuda: 'Cafe, energizantes u otros estimulantes.',
      icono: Icons.coffee_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Nutricion inteligente',
      pregunta: 'Con que frecuencia consume lacteos?',
      tipo: _RespuestaTipo.frecuencia,
      icono: Icons.icecream_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Nutricion inteligente',
      pregunta: 'Con que frecuencia consume embutidos?',
      tipo: _RespuestaTipo.frecuencia,
      icono: Icons.set_meal_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Nutricion inteligente',
      pregunta: 'Con que frecuencia consume alcohol?',
      tipo: _RespuestaTipo.frecuencia,
      icono: Icons.wine_bar_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Bloque espiritual y emocional',
      pregunta: 'Lee la Biblia?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Nunca', 'Ocasionalmente', 'Frecuentemente', 'Diario'],
      icono: Icons.menu_book_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Bloque espiritual y emocional',
      pregunta: 'Habla directamente con Dios?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Nunca', 'A veces', 'Frecuentemente', 'Diario'],
      icono: Icons.volunteer_activism_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Bloque espiritual y emocional',
      pregunta: 'Como describiria su nivel de estres?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Muy bajo', 'Bajo', 'Moderado', 'Alto', 'Muy alto'],
      icono: Icons.self_improvement_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Bloque familiar',
      pregunta: 'Familiares vivos y enfermedades importantes',
      tipo: _RespuestaTipo.texto,
      ayuda:
          'Incluye enfermedades metabolicas, cancer, autoinmunes o neurologicas.',
      icono: Icons.family_restroom_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Bloque familiar',
      pregunta: 'Familiares fallecidos: causa y edad aproximada',
      tipo: _RespuestaTipo.texto,
      icono: Icons.history_edu_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Modulo perinatal',
      pregunta:
          'Que sabe sobre su embarazo, nacimiento o primeros meses de vida?',
      tipo: _RespuestaTipo.texto,
      ayuda:
          'Prematuridad, bajo peso, complicaciones, estres materno o lactancia.',
      icono: Icons.child_care_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Modulo mujer',
      pregunta: 'Si corresponde, marque antecedentes ginecologicos relevantes',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'SOP',
        'Infertilidad',
        'Endometriosis',
        'Menopausia',
        'Anticonceptivos hormonales previos',
        'Lactancia',
        'No corresponde',
      ],
      icono: Icons.female_outlined,
    ),
    _PreguntaClinica(
      modulo: 'Modulo varon',
      pregunta: 'Si corresponde, marque antecedentes masculinos relevantes',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Ereccion matutina disminuida',
        'Disfuncion erectil',
        'Fertilidad',
        'Frecuencia urinaria nocturna',
        'Libido baja',
        'No corresponde',
      ],
      icono: Icons.male_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarBorrador().then((_) {
        if (mounted) {
          context.read<ChatbotBloc>().add(const VerificarEstadoEvent());
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    _respuestaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _leer(String texto) async {
    final version = ++_ttsVersion;
    final datasource = context.read<ChatbotBloc>().datasource;
    await _audioPlayer.stop();
    setState(() => _textoReproduciendo = texto);
    try {
      final bytes = await datasource.tts(texto);
      if (_ttsVersion != version || !mounted) return;
      await _audioPlayer.play(BytesSource(bytes));
    } catch (_) {
      // falla silenciosamente: TTS es complementario
    } finally {
      if (_ttsVersion == version && mounted) {
        setState(() => _textoReproduciendo = null);
      }
    }
  }

  Future<void> _detener() async {
    _ttsVersion++;
    await _audioPlayer.stop();
    if (mounted) setState(() => _textoReproduciendo = null);
  }

  void _leerPreguntaActual() {
    if (!_enModoFormulario) return;
    final texto = _preguntas[_preguntaActual].pregunta;
    _leer(texto);
  }

  Future<void> _cargarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    final resumen = prefs.getStringList(_borradorResumenKey) ?? [];
    final pendientes = prefs.getStringList(_borradorPendientesKey) ?? [];
    if (resumen.isEmpty && pendientes.isEmpty) return;
    final preguntaGuardada = prefs.getInt(_borradorPreguntaKey) ?? 0;

    setState(() {
      _preguntaActual = preguntaGuardada
          .clamp(0, _preguntas.length - 1)
          .toInt();
      _flujoCompletado = prefs.getBool(_borradorCompletadoKey) ?? false;
      _resumenRespuestas
        ..clear()
        ..addAll(resumen);
      _respuestasAcumuladas
        ..clear()
        ..addAll(pendientes);
      _borradorRestaurado = true;
    });
  }

  Future<void> _guardarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_borradorPreguntaKey, _preguntaActual);
    await prefs.setBool(_borradorCompletadoKey, _flujoCompletado);
    await prefs.setStringList(_borradorPendientesKey, _respuestasAcumuladas);
    await prefs.setStringList(_borradorResumenKey, _resumenRespuestas);
  }

  Future<void> _limpiarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_borradorPreguntaKey);
    await prefs.remove(_borradorCompletadoKey);
    await prefs.remove(_borradorPendientesKey);
    await prefs.remove(_borradorResumenKey);
  }

  bool get _enModoFormulario {
    if (_esNuevo == null) return false;
    if (_esNuevo!) return !_flujoCompletado;
    return _mostrarFormulario && !_flujoCompletado;
  }

  // Avanza al siguiente índice no saltado; si no hay más, completa el flujo
  void _avanzarPregunta() {
    int siguiente = _preguntaActual + 1;
    while (siguiente < _preguntas.length &&
        _indicesSaltados.contains(siguiente)) {
      siguiente++;
    }
    if (siguiente < _preguntas.length) {
      _preguntaActual = siguiente;
    } else {
      _flujoCompletado = true;
      _mostrarFormulario = false;
    }
  }

  static String _edadAOpcion(int edad) {
    if (edad < 18) return 'Menos de 18';
    if (edad <= 29) return '18 a 29';
    if (edad <= 44) return '30 a 44';
    if (edad <= 59) return '45 a 59';
    return '60 o mas';
  }

  void _enviarBatch() {
    if (_respuestasAcumuladas.isEmpty) return;
    final batch = _respuestasAcumuladas.join('\n\n');
    _respuestasAcumuladas.clear();
    _guardarBorrador();
    context.read<ChatbotBloc>().add(
      EnviarMensajeEvent(
        batch,
        mostrarMensajeEnChat: false,
        mostrarRespuestaAsistente: false,
      ),
    );
  }

  void _enviar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    _controller.clear();
    _debeScrollChat = true;
    context.read<ChatbotBloc>().add(EnviarMensajeEvent(texto));
  }

  void _enviarRespuestaGuiada(String respuesta) {
    final pregunta = _preguntas[_preguntaActual];
    final texto =
        '''
${pregunta.modulo}
${pregunta.pregunta}
Respuesta: $respuesta
'''
            .trim();

    _respuestasAcumuladas.add(texto);
    _resumenRespuestas.add(texto);
    _respuestaController.clear();
    _seleccionMultiple.clear();
    _valorEscala = 5;

    setState(() => _avanzarPregunta());
    _guardarBorrador();

    if (_flujoCompletado && _respuestasAcumuladas.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _enviarBatch();
      });
    } else if (!_flujoCompletado) {
      // Leer la siguiente pregunta al aparecer
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _leerPreguntaActual();
      });
    }
  }

  bool _esOpcionExcluyente(String opcion) {
    final normalizada = opcion.toLowerCase();
    return normalizada == 'ninguno' ||
        normalizada == 'ninguna' ||
        normalizada == 'ninguna conocida' ||
        normalizada == 'no corresponde' ||
        normalizada == 'no me operaron' ||
        normalizada == 'no sabe' ||
        normalizada == 'nada claro';
  }

  void _omitirPregunta() {
    _enviarRespuestaGuiada('Prefiere omitir por ahora');
  }

  void _scrollAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatbotBloc, ChatbotState>(
      listener: (context, state) {
        if (state is EstadoCargado) {
          final p = state.perfil;
          final partes = <String>[];
          final saltados = <int>{};

          if (p.nombreCompleto != null && p.nombreCompleto!.isNotEmpty) {
            partes.add('- Nombre completo: ${p.nombreCompleto}');
            saltados.add(0);
          }
          if (p.edad != null) {
            partes.add('- Edad: ${p.edad} años (${_edadAOpcion(p.edad!)})');
            saltados.add(1);
          }
          if (p.fechaNacimiento != null) {
            final fn = p.fechaNacimiento!;
            partes.add(
              '- Fecha de nacimiento: ${fn.day.toString().padLeft(2, '0')}/${fn.month.toString().padLeft(2, '0')}/${fn.year}',
            );
            saltados.add(2);
          }
          if (p.telefono != null && p.telefono!.isNotEmpty) {
            partes.add('- Teléfono: ${p.telefono}');
            saltados.add(5);
          }

          // Primera pregunta que no está saltada
          int primero = 0;
          while (primero < _preguntas.length && saltados.contains(primero)) {
            primero++;
          }

          setState(() {
            _esNuevo = state.esNuevo;
            _indicesSaltados.addAll(saltados);
            if (!_borradorRestaurado) {
              _preguntaActual = primero;
            }
          });

          if (partes.isNotEmpty && !_perfilPrecargado) {
            _perfilPrecargado = true;
            _respuestasAcumuladas.insert(
              0,
              'Información del perfil del paciente (ya registrada en el sistema):\n${partes.join('\n')}',
            );
            _guardarBorrador();
          }

          if (!state.esNuevo && !_saludoEnviado) {
            _saludoEnviado = true;
            _debeScrollChat = true;
            context.read<ChatbotBloc>().add(
              const EnviarMensajeEvent(
                'El paciente ha abierto el chat. Saludalo por su nombre y preguntale el motivo de su consulta de hoy, mencionando que tienes acceso a su historial previo.',
                mostrarMensajeEnChat: false,
                mostrarRespuestaAsistente: true,
              ),
            );
          } else if (state.esNuevo) {
            // Leer la primera pregunta del cuestionario
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _leerPreguntaActual();
            });
          }
        }
        if (_debeScrollChat &&
            (state is MensajeRecibido || state is ChatbotEscribiendo)) {
          _scrollAbajo();
        }
        if (state is MensajeRecibido) {
          _debeScrollChat = false;
          // Auto-reproducir respuesta visible de la IA
          final ultimo = state.mensajes.isNotEmpty ? state.mensajes.last : null;
          if (ultimo != null && !ultimo.esUsuario) {
            _leer(ultimo.contenido);
          }
        }
        if (state is ChatbotError) {
          _debeScrollChat = false;
        }
        if (state is ConversacionFinalizada) {
          _limpiarBorrador();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Historia clinica guardada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is ChatbotError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (_esNuevo == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6FAFA),
            appBar: AppBar(
              title: const Text('Asistente medico'),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final mensajes = switch (state) {
          ChatbotEscribiendo s => s.mensajes,
          MensajeRecibido s => s.mensajes,
          ChatbotError s => s.mensajes,
          _ => <MensajeChat>[],
        };
        final escribiendo = state is ChatbotEscribiendo;
        final listo = state is MensajeRecibido && state.listo;
        final finalizando = state is ConversacionFinalizada;
        final disabled = escribiendo || finalizando;
        final enFormulario = _enModoFormulario;

        return Scaffold(
          backgroundColor: const Color(0xFFF6FAFA),
          appBar: AppBar(
            title: const Text('Asistente medico'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: [
              if (!_esNuevo!)
                IconButton(
                  icon: Icon(
                    _mostrarFormulario
                        ? Icons.chat_outlined
                        : Icons.assignment_outlined,
                  ),
                  tooltip: _mostrarFormulario
                      ? 'Volver al chat'
                      : 'Llenar formulario completo',
                  onPressed: () => setState(() {
                    _mostrarFormulario = !_mostrarFormulario;
                    if (_mostrarFormulario) {
                      if (!_borradorRestaurado) {
                        _preguntaActual = 0;
                      }
                      _flujoCompletado = false;
                    }
                  }),
                ),
              if (mensajes.isNotEmpty && !escribiendo && !finalizando)
                TextButton.icon(
                  onPressed: () => _confirmarFinalizar(context),
                  icon: Icon(
                    listo ? Icons.check_circle : Icons.stop_circle_outlined,
                    color: listo ? Colors.green : Colors.black54,
                  ),
                  label: Text(
                    listo ? 'Guardar' : 'Finalizar',
                    style: TextStyle(
                      color: listo ? Colors.green : Colors.black54,
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  children: [
                    if (enFormulario) ...[
                      _buildEncabezado(mensajes.isEmpty),
                      const SizedBox(height: 12),
                      _buildPreguntaActual(disabled),
                      const SizedBox(height: 12),
                      if (mensajes.isEmpty) _buildNotaClinica(),
                    ] else ...[
                      if (_esNuevo! && _flujoCompletado)
                        _buildFlujoCompletado(disabled),
                      if (mensajes.isEmpty && !escribiendo) _buildNotaClinica(),
                      for (final mensaje in mensajes) _buildBurbuja(mensaje),
                      if (escribiendo) _buildBurbujaPensando(),
                    ],
                  ],
                ),
              ),
              if (!enFormulario) _buildInputBar(disabled),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEncabezado(bool primeraVez) {
    final theme = Theme.of(context);
    final progreso = _flujoCompletado
        ? 1.0
        : (_preguntaActual + 1) / _preguntas.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_information_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Preconsulta medica CIEMSI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/asistente/asistente_escribiendo.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            primeraVez
                ? 'Responde paso a paso. Puedes elegir opciones o escribir con tus palabras cuando lo necesites.'
                : 'Seguimos ordenando tus datos para que el equipo medico tenga un resumen claro.',
            style: const TextStyle(color: Colors.white, height: 1.35),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _flujoCompletado
                ? 'Cuestionario completado'
                : 'Pregunta ${_preguntaActual + 1} de ${_preguntas.length}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFlujoCompletado(bool disabled) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0ECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Preconsulta completada',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Image.asset(
                'assets/images/asistente/asistente_senalando.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Puedes agregar algun comentario libre abajo o guardar la informacion recopilada.',
            style: TextStyle(color: Colors.black54, height: 1.35),
          ),
          if (_resumenRespuestas.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildResumenPreconsulta(compacto: true),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: disabled ? null : () => _confirmarFinalizar(context),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar preconsulta'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreguntaActual(bool disabled) {
    final pregunta = _preguntas[_preguntaActual];
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0ECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  pregunta.icono,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pregunta.modulo,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pregunta.pregunta,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (pregunta.ayuda != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        pregunta.ayuda!,
                        style: const TextStyle(
                          color: Colors.black54,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildControlRespuesta(pregunta, disabled),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: disabled ? null : _omitirPregunta,
              child: const Text('Omitir por ahora'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlRespuesta(_PreguntaClinica pregunta, bool disabled) {
    switch (pregunta.tipo) {
      case _RespuestaTipo.texto:
        return _buildRespuestaTexto(disabled);
      case _RespuestaTipo.multiple:
        return _buildSeleccionMultiple(pregunta.opciones, disabled);
      case _RespuestaTipo.unica:
        return _buildSeleccionUnica(pregunta.opciones, disabled);
      case _RespuestaTipo.escala:
        return _buildEscala(disabled);
      case _RespuestaTipo.frecuencia:
        return _buildSeleccionUnica(_frecuencias, disabled);
      case _RespuestaTipo.zonaCuerpo:
        return _buildZonasCuerpo(disabled);
    }
  }

  Widget _buildRespuestaTexto(bool disabled) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _respuestaController,
            enabled: !disabled,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta',
              filled: true,
              fillColor: const Color(0xFFF4F8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: disabled
              ? null
              : () {
                  final respuesta = _respuestaController.text.trim();
                  if (respuesta.isNotEmpty) _enviarRespuestaGuiada(respuesta);
                },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Enviar'),
        ),
      ],
    );
  }

  Widget _buildSeleccionMultiple(List<String> opciones, bool disabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final opcion in opciones)
              FilterChip(
                label: Text(opcion),
                selected: _seleccionMultiple.contains(opcion),
                onSelected: disabled
                    ? null
                    : (selected) {
                        setState(() {
                          if (_esOpcionExcluyente(opcion)) {
                            _seleccionMultiple
                              ..clear()
                              ..add(opcion);
                          } else {
                            _seleccionMultiple.removeWhere(_esOpcionExcluyente);
                            if (selected) {
                              _seleccionMultiple.add(opcion);
                            } else {
                              _seleccionMultiple.remove(opcion);
                            }
                          }
                        });
                      },
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _respuestaController,
          enabled: !disabled,
          minLines: 1,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Detalle opcional',
            filled: true,
            fillColor: const Color(0xFFF4F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: disabled || _seleccionMultiple.isEmpty
              ? null
              : () {
                  final detalle = _respuestaController.text.trim();
                  final respuesta = _seleccionMultiple.join(', ');
                  _enviarRespuestaGuiada(
                    detalle.isEmpty
                        ? respuesta
                        : '$respuesta. Detalle: $detalle',
                  );
                },
          icon: const Icon(Icons.check),
          label: const Text('Confirmar seleccion'),
        ),
      ],
    );
  }

  Widget _buildSeleccionUnica(List<String> opciones, bool disabled) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final opcion in opciones)
          ChoiceChip(
            label: Text(opcion),
            selected: false,
            onSelected: disabled ? null : (_) => _enviarRespuestaGuiada(opcion),
          ),
      ],
    );
  }

  Widget _buildEscala(bool disabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.sentiment_satisfied_alt_outlined),
            Expanded(
              child: Slider(
                value: _valorEscala,
                min: 0,
                max: 10,
                divisions: 10,
                label: _valorEscala.round().toString(),
                onChanged: disabled
                    ? null
                    : (value) => setState(() => _valorEscala = value),
              ),
            ),
            const Icon(Icons.sentiment_very_dissatisfied_outlined),
          ],
        ),
        Center(
          child: Text(
            _valorEscala.round().toString(),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: disabled
              ? null
              : () => _enviarRespuestaGuiada(_valorEscala.round().toString()),
          icon: const Icon(Icons.check),
          label: const Text('Confirmar intensidad'),
        ),
      ],
    );
  }

  Widget _buildZonasCuerpo(bool disabled) {
    final iconos = {
      'Cabeza': Icons.face_outlined,
      'Pecho': Icons.favorite_border,
      'Abdomen': Icons.radio_button_unchecked,
      'Espalda': Icons.accessibility_new_outlined,
      'Pelvis': Icons.airline_seat_legroom_normal_outlined,
      'Brazo/mano': Icons.back_hand_outlined,
      'Pierna/pie': Icons.directions_walk_outlined,
      'Todo el cuerpo': Icons.accessibility_outlined,
    };

    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 520 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.8,
      children: [
        for (final zona in _zonasCuerpo)
          OutlinedButton.icon(
            onPressed: disabled ? null : () => _enviarRespuestaGuiada(zona),
            icon: Icon(iconos[zona] ?? Icons.location_on_outlined),
            label: Text(zona, overflow: TextOverflow.ellipsis),
          ),
      ],
    );
  }

  Widget _buildResumenPreconsulta({bool compacto = false}) {
    final porModulo = <String, List<String>>{};

    for (final item in _resumenRespuestas) {
      final lineas = item.split('\n');
      if (lineas.length < 3) continue;
      final modulo = lineas[0].trim();
      final pregunta = lineas[1].trim();
      final respuesta = lineas.sublist(2).join('\n').trim();
      porModulo.putIfAbsent(modulo, () => []).add('$pregunta\n$respuesta');
    }

    if (porModulo.isEmpty) {
      return const Text(
        'Aún no hay respuestas para resumir.',
        style: TextStyle(color: Colors.black54),
      );
    }

    final modulos = porModulo.entries.toList();
    final visibles = compacto ? modulos.take(3).toList() : modulos;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0ECEC)),
      ),
      child: Column(
        children: [
          for (final entry in visibles)
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              initiallyExpanded: !compacto && visibles.length <= 3,
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${entry.value.length} respuesta(s)'),
              children: [
                for (final respuesta in entry.value)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        respuesta,
                        style: const TextStyle(height: 1.35),
                      ),
                    ),
                  ),
              ],
            ),
          if (compacto && modulos.length > visibles.length)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '+${modulos.length - visibles.length} módulo(s) más en el resumen final',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotaClinica() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF8A6500)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Este asistente organiza informacion para una preconsulta. No reemplaza una valoracion medica ni una atencion de emergencia.',
              style: TextStyle(color: Color(0xFF654A00), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarAsistente(String pose) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8F7F9),
        border: Border.all(color: const Color(0xFF00B5C8), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(pose, fit: BoxFit.cover),
    );
  }

  Widget _buildBurbuja(MensajeChat msg) {
    final esUsuario = msg.esUsuario;
    final theme = Theme.of(context);

    final burbuja = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        color: esUsuario ? theme.colorScheme.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(esUsuario ? 16 : 4),
          bottomRight: Radius.circular(esUsuario ? 4 : 16),
        ),
        border: esUsuario ? null : Border.all(color: const Color(0xFFE0ECEC)),
      ),
      child: Text(
        msg.contenido,
        style: TextStyle(
          color: esUsuario
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontSize: 15,
          height: 1.35,
        ),
      ),
    );

    if (esUsuario) {
      return Align(alignment: Alignment.centerRight, child: burbuja);
    }

    final estaReproduciendo = _textoReproduciendo == msg.contenido;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildAvatarAsistente(
          'assets/images/asistente/asistente_explicando.png',
        ),
        const SizedBox(width: 8),
        Flexible(child: burbuja),
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            estaReproduciendo
                ? Icons.stop_circle_outlined
                : Icons.volume_up_outlined,
            size: 20,
            color: estaReproduciendo
                ? const Color(0xFF00B5C8)
                : Colors.grey.shade400,
          ),
          onPressed: estaReproduciendo ? _detener : () => _leer(msg.contenido),
        ),
      ],
    );
  }

  Widget _buildBurbujaPensando() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildAvatarAsistente('assets/images/asistente/asistente_pensando.png'),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: const Color(0xFFE0ECEC)),
          ),
          child: const _TypingIndicator(),
        ),
      ],
    );
  }

  Widget _buildInputBar(bool disabled) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !disabled,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Comentario opcional para esta preconsulta...',
                  filled: true,
                  fillColor: const Color(0xFFF4F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: disabled ? null : (_) => _enviar(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: disabled
                  ? Colors.grey
                  : Theme.of(context).colorScheme.primary,
              child: IconButton(
                onPressed: disabled ? null : _enviar,
                tooltip: 'Enviar comentario',
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarFinalizar(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar consulta'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revisa el resumen antes de guardar la información recopilada en tu historial clínico.',
                ),
                if (_resumenRespuestas.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildResumenPreconsulta(),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      context.read<ChatbotBloc>().add(const FinalizarConversacionEvent());
    }
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final opacity = ((_anim.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * opacity;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha((opacity * 200 + 55).round()),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
