import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/asistente_bloc.dart';
import '../bloc/asistente_event.dart';
import '../bloc/asistente_state.dart';

enum _RespuestaTipo { texto, numero, fecha, hora, unica, multiple }

bool _esSi(String respuesta) {
  final normalizada = respuesta.trim().toLowerCase();
  return normalizada == 'sí' || normalizada == 'si';
}

bool _noEsNinguno(String respuesta) =>
    !respuesta.trim().toLowerCase().startsWith('ninguno');

class _PreguntaClinica {
  final String id;
  final String modulo;
  final String pregunta;
  final _RespuestaTipo tipo;
  final List<String> opciones;
  final String? ayuda;
  final IconData icono;
  final bool multilinea;
  final bool ocultarSiMasculino;
  final bool soloMasculino;
  final String? dependeDeId;
  final bool Function(String respuesta)? mostrarSi;

  const _PreguntaClinica({
    required this.id,
    required this.modulo,
    required this.pregunta,
    required this.tipo,
    this.opciones = const [],
    this.ayuda,
    this.icono = Icons.medical_information_outlined,
    this.multilinea = false,
    this.ocultarSiMasculino = false,
    this.soloMasculino = false,
    this.dependeDeId,
    this.mostrarSi,
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
  bool _flujoCompletado = false;
  bool _debeScrollChat = false;
  bool _saludoEnviado = false;
  bool _mostrarFormulario = false;
  bool? _esNuevo; // null = cargando
  String? _generoPaciente; // 'M', 'F' o null
  final Set<String> _idsAutoCompletados = {};
  final Map<String, String> _respuestasPorId = {};
  final List<String> _respuestasAcumuladas = [];
  final List<String> _resumenRespuestas = [];
  final Set<String> _seleccionMultiple = {};
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  bool _borradorRestaurado = false;
  bool _perfilPrecargado = false;

  static const _borradorPreguntaKey = 'asistente_borrador_pregunta';
  static const _borradorCompletadoKey = 'asistente_borrador_completado';
  static const _borradorPendientesKey = 'asistente_borrador_pendientes';
  static const _borradorResumenKey = 'asistente_borrador_resumen';
  static const _borradorRespuestasKey = 'asistente_borrador_respuestas';

  // TTS
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _textoReproduciendo;
  int _ttsVersion = 0;
  bool _modoAudible = true;
  static const _modoAudibleKey = 'asistente_modo_audible';

  static const _preguntas = [
    // BLOQUE 1: DATOS PERSONALES E IDENTIFICACION
    _PreguntaClinica(
      id: 'Q1',
      modulo: 'Bloque 1: Datos personales e identificación',
      pregunta: 'Nombres y Apellidos Completos',
      tipo: _RespuestaTipo.texto,
      icono: Icons.badge_outlined,
    ),
    _PreguntaClinica(
      id: 'Q2',
      modulo: 'Bloque 1: Datos personales e identificación',
      pregunta: 'Edad (años cumplidos)',
      tipo: _RespuestaTipo.numero,
      icono: Icons.cake_outlined,
    ),
    _PreguntaClinica(
      id: 'Q3',
      modulo: 'Bloque 1: Datos personales e identificación',
      pregunta: 'Fecha de Nacimiento',
      tipo: _RespuestaTipo.fecha,
      icono: Icons.event_outlined,
    ),
    _PreguntaClinica(
      id: 'Q4',
      modulo: 'Bloque 1: Datos personales e identificación',
      pregunta: 'Lugar de Nacimiento (Ciudad, Departamento/Estado, País)',
      tipo: _RespuestaTipo.texto,
      icono: Icons.place_outlined,
    ),
    _PreguntaClinica(
      id: 'Q5',
      modulo: 'Bloque 1: Datos personales e identificación',
      pregunta: 'Lugares de residencia anteriores',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      ayuda:
          'Mencione las ciudades o países donde ha vivido por más de 6 meses.',
      icono: Icons.map_outlined,
    ),
    _PreguntaClinica(
      id: 'Q6',
      modulo: 'Bloque 1: Datos personales e identificación',
      pregunta: 'Dirección de domicilio actual',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      ayuda: 'Incluya zona o barrio, ciudad y país.',
      icono: Icons.home_outlined,
    ),
    _PreguntaClinica(
      id: 'Q7',
      modulo: 'Bloque 1: Datos personales e identificación',
      pregunta: 'Teléfono celular de contacto',
      tipo: _RespuestaTipo.texto,
      icono: Icons.phone_outlined,
    ),
    _PreguntaClinica(
      id: 'Q8',
      modulo: 'Bloque 1: Datos personales e identificación',
      pregunta: 'Teléfono celular de un familiar o contacto de emergencia',
      tipo: _RespuestaTipo.texto,
      ayuda: 'Obligatorio si es menor de edad o adulto mayor.',
      icono: Icons.contact_phone_outlined,
    ),

    // BLOQUE 2: ANTECEDENTES MEDICOS Y QUIRURGICOS
    _PreguntaClinica(
      id: 'Q10',
      modulo: 'Bloque 2: Antecedentes médicos y quirúrgicos',
      pregunta: '¿Tiene antecedentes de cirugías (operaciones quirúrgicas)?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Sí', 'No'],
      icono: Icons.local_hospital_outlined,
    ),
    _PreguntaClinica(
      id: 'Q11',
      modulo: 'Bloque 2: Antecedentes médicos y quirúrgicos',
      pregunta: 'Detalle sus cirugías',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      ayuda:
          'Qué le operaron, en qué año aproximado y si hubo alguna complicación.',
      icono: Icons.healing_outlined,
      dependeDeId: 'Q10',
      mostrarSi: _esSi,
    ),
    _PreguntaClinica(
      id: 'Q12',
      modulo: 'Bloque 2: Antecedentes médicos y quirúrgicos',
      pregunta:
          '¿Ha padecido alguna enfermedad que requiriera tratamiento médico continuo por una semana o más?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Sí', 'No'],
      icono: Icons.assignment_outlined,
    ),
    _PreguntaClinica(
      id: 'Q13',
      modulo: 'Bloque 2: Antecedentes médicos y quirúrgicos',
      pregunta: 'Detalle de enfermedades anteriores',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      ayuda:
          'Nombre de la enfermedad, medicamentos que tomó y por cuánto tiempo.',
      icono: Icons.medical_information_outlined,
      dependeDeId: 'Q12',
      mostrarSi: _esSi,
    ),
    _PreguntaClinica(
      id: 'Q14',
      modulo: 'Bloque 2: Antecedentes médicos y quirúrgicos',
      pregunta: '¿Ha sido hospitalizado alguna vez?',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      ayuda:
          "Si es así, indique brevemente la causa y el año. De lo contrario, escriba 'No'.",
      icono: Icons.local_hospital_outlined,
    ),
    _PreguntaClinica(
      id: 'Q15',
      modulo: 'Bloque 2: Antecedentes médicos y quirúrgicos',
      pregunta: '¿Ha recibido transfusiones de sangre en el pasado?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Sí', 'No', 'No lo sé'],
      icono: Icons.bloodtype_outlined,
    ),
    _PreguntaClinica(
      id: 'Q16',
      modulo: 'Bloque 2: Antecedentes médicos y quirúrgicos',
      pregunta: '¿Tiene alergias conocidas?',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      ayuda:
          "Medicamentos, alimentos, sustancias, insectos, etc. Indicar 'Ninguna' si no presenta.",
      icono: Icons.warning_amber_outlined,
    ),
    _PreguntaClinica(
      id: 'Q17',
      modulo: 'Bloque 2: Antecedentes médicos y quirúrgicos',
      pregunta:
          '¿Toma algún medicamento, suplemento o hierba medicinal de forma regular actualmente?',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      ayuda:
          "Indique nombre y dosis si los recuerda. De lo contrario, escriba 'Ninguno'.",
      icono: Icons.medication_outlined,
    ),

    // BLOQUE 3: ESTILO DE VIDA Y HABITOS DE SALUD
    _PreguntaClinica(
      id: 'Q18',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta:
          '¿En su entorno laboral o actividades diarias, está expuesto regularmente a alguno de los siguientes factores?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Sedentarismo (pasar mucho tiempo sentado)',
        'Cargar objetos pesados',
        'Estrés excesivo',
        'Calor extremo',
        'Frío extremo',
        'Cambios bruscos de temperatura',
        'Humos, polvos o vapores',
        'Sustancias químicas',
        'Riesgo de golpes o caídas',
        'Ninguno de los anteriores',
      ],
      icono: Icons.factory_outlined,
    ),
    _PreguntaClinica(
      id: 'Q19',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta: '¿En promedio, cuántas veces orina durante el día?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Menos de 4 veces', 'De 4 a 7 veces', 'Más de 7 veces'],
      icono: Icons.water_drop_outlined,
    ),
    _PreguntaClinica(
      id: 'Q20',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta: '¿Cuál es su frecuencia habitual de evacuación intestinal?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Más de 3 veces al día',
        '1 a 2 veces al día',
        'Día por medio (cada 48 horas)',
        '2 veces por semana o menos',
      ],
      icono: Icons.monitor_heart_outlined,
    ),
    _PreguntaClinica(
      id: 'Q21',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta: '¿Qué cantidad de agua pura consume al día?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Menos de 500 ml (menos de 2 vasos)',
        'Entre 500 ml y 1 litro (2 a 4 vasos)',
        'Entre 1 y 2 litros (4 a 8 vasos)',
        'Más de 2 litros (más de 8 vasos)',
      ],
      ayuda: 'No cuente mates, cafés, jugos ni refrescos.',
      icono: Icons.local_drink_outlined,
    ),
    _PreguntaClinica(
      id: 'Q22',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta: 'Hora habitual en la que se acuesta a dormir',
      tipo: _RespuestaTipo.hora,
      icono: Icons.bedtime_outlined,
    ),
    _PreguntaClinica(
      id: 'Q23',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta: 'Hora habitual en la que se despierta',
      tipo: _RespuestaTipo.hora,
      icono: Icons.wb_sunny_outlined,
    ),
    _PreguntaClinica(
      id: 'Q24',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta: '¿Presenta alguna dificultad con su sueño?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'No, duermo bien y descanso',
        'Dificultad para conciliar el sueño (insomnio)',
        'Me despierto varias veces en la noche',
        'Despertar muy temprano y no poder volver a dormir',
        'Ronquidos fuertes o pausas respiratorias',
        'Pesadillas o sudoración nocturna',
      ],
      icono: Icons.nightlight_outlined,
    ),
    _PreguntaClinica(
      id: 'Q25',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta:
          '¿Con qué frecuencia realiza actividad física o ejercicio (mínimo 30 minutos)?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Nunca / Sedentario',
        'Rara vez (menos de 1 vez por semana)',
        '1 a 2 veces por semana',
        '3 o más veces por semana',
      ],
      icono: Icons.directions_run_outlined,
    ),
    _PreguntaClinica(
      id: 'Q26',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta:
          '¿Con qué frecuencia toma baños de sol directos sobre la piel durante 10 a 15 minutos?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Nunca o casi nunca',
        '1 a 2 veces por semana',
        '3 o más veces por semana',
        'Todos los días',
      ],
      ayuda: 'Brazos o piernas, no solo la cara.',
      icono: Icons.wb_sunny_outlined,
    ),
    _PreguntaClinica(
      id: 'Q27',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta:
          '¿Con qué frecuencia pasa tiempo en espacios naturales abiertos?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Nunca o casi nunca',
        'Rara vez (una vez al mes)',
        'Ocasionalmente (una vez por semana)',
        'Frecuentemente (varias veces por semana o vive en el campo)',
      ],
      ayuda: 'Campo, parques grandes con árboles.',
      icono: Icons.park_outlined,
    ),
    _PreguntaClinica(
      id: 'Q28',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta:
          '¿Con qué frecuencia realiza prácticas espirituales, de oración o lectura meditativa?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Diariamente', 'Varias veces por semana', 'Ocasionalmente', 'Nunca'],
      icono: Icons.menu_book_outlined,
    ),
    _PreguntaClinica(
      id: 'Q29',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta: '¿Con qué frecuencia consume tabaco (fuma)?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Nunca (No consumo)',
        'Consumía en el pasado pero ya no',
        'Ocasionalmente (Eventos sociales)',
        'Frecuentemente (Diario o varias veces por semana)',
      ],
      icono: Icons.smoking_rooms_outlined,
    ),
    _PreguntaClinica(
      id: 'Q30',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta: '¿Con qué frecuencia ingiere bebidas alcohólicas?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Nunca (No consumo)',
        'Consumía en el pasado pero ya no',
        'Ocasionalmente (Eventos sociales)',
        'Frecuentemente (Diario o varias veces por semana)',
      ],
      icono: Icons.wine_bar_outlined,
    ),
    _PreguntaClinica(
      id: 'Q31',
      modulo: 'Bloque 3: Estilo de vida y hábitos de salud',
      pregunta:
          '¿Con qué frecuencia consume otro tipo de sustancias o drogas no recetadas?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Nunca (No consumo)',
        'Consumía en el pasado pero ya no',
        'Ocasionalmente',
        'Frecuentemente',
      ],
      icono: Icons.medication_liquid_outlined,
    ),

    // BLOQUE 4: ALIMENTACION Y NUTRICION
    _PreguntaClinica(
      id: 'Q32',
      modulo: 'Bloque 4: Alimentación y nutrición',
      pregunta:
          'Marque los alimentos o productos que consume con regularidad en su dieta semanal',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Té o té verde',
        'Café',
        'Chocolate / Cocoa / Toddy',
        'Leche de vaca',
        'Queso',
        'Yogurt',
        'Mantequilla',
        'Embutidos (salchichas, mortadela, carnes frías)',
        'Gaseosas o jugos envasados',
        'Galletas, masitas o golosinas',
        'Alimentos ultraprocesados / empaquetados',
        'Menudencias (hígado, panza, etc.)',
        'Ninguno de los anteriores',
      ],
      icono: Icons.restaurant_outlined,
    ),
    _PreguntaClinica(
      id: 'Q33',
      modulo: 'Bloque 4: Alimentación y nutrición',
      pregunta:
          'Describa detalladamente los alimentos que incluyó en su último Desayuno',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      icono: Icons.free_breakfast_outlined,
    ),
    _PreguntaClinica(
      id: 'Q34',
      modulo: 'Bloque 4: Alimentación y nutrición',
      pregunta:
          'Describa detalladamente los alimentos que incluyó en su último Almuerzo',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      icono: Icons.lunch_dining_outlined,
    ),
    _PreguntaClinica(
      id: 'Q35',
      modulo: 'Bloque 4: Alimentación y nutrición',
      pregunta:
          'Describa detalladamente los alimentos que incluyó en su última Cena',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      icono: Icons.dinner_dining_outlined,
    ),
    _PreguntaClinica(
      id: 'Q36',
      modulo: 'Bloque 4: Alimentación y nutrición',
      pregunta:
          '¿Qué suele consumir a media mañana y/o media tarde (meriendas)?',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      icono: Icons.icecream_outlined,
    ),

    // BLOQUE 5: ANTECEDENTES FAMILIARES
    _PreguntaClinica(
      id: 'Q37',
      modulo: 'Bloque 5: Antecedentes familiares',
      pregunta:
          'Seleccione si algún familiar directo (primer grado) ha fallecido o padece alguna enfermedad crónica relevante',
      tipo: _RespuestaTipo.multiple,
      opciones: ['Padre', 'Madre', 'Hermano(a)', 'Hijo(a)', 'Abuelos', 'Ninguno'],
      icono: Icons.family_restroom_outlined,
    ),
    _PreguntaClinica(
      id: 'Q38',
      modulo: 'Bloque 5: Antecedentes familiares',
      pregunta:
          'Detalle las causas de fallecimiento o enfermedades de los familiares seleccionados',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      ayuda:
          'Especifique qué familiar y qué enfermedad padece o causó su deceso (ej. Diabetes, Hipertensión, Cáncer, etc.).',
      icono: Icons.history_edu_outlined,
      dependeDeId: 'Q37',
      mostrarSi: _noEsNinguno,
    ),

    // BLOQUE 6: ANTECEDENTES DE NACIMIENTO Y DESARROLLO
    _PreguntaClinica(
      id: 'Q39',
      modulo: 'Bloque 6: Antecedentes de nacimiento y desarrollo',
      pregunta: '¿Qué edad aproximada tenía su madre cuando usted nació?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Menos de 20 años',
        'Entre 20 y 25 años',
        'Entre 26 y 35 años',
        'Más de 35 años',
        'No lo sé',
      ],
      icono: Icons.pregnant_woman_outlined,
    ),
    _PreguntaClinica(
      id: 'Q40',
      modulo: 'Bloque 6: Antecedentes de nacimiento y desarrollo',
      pregunta:
          '¿Qué número de hijo es usted en el orden de nacimiento de su madre?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Primer hijo',
        'Segundo hijo',
        'Tercer hijo',
        'Cuarto hijo',
        'Quinto hijo o más',
      ],
      icono: Icons.looks_one_outlined,
    ),
    _PreguntaClinica(
      id: 'Q41',
      modulo: 'Bloque 6: Antecedentes de nacimiento y desarrollo',
      pregunta: 'Diferencia de edad con el hermano nacido ANTES que usted',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'No tengo hermanos mayores',
        'Menos de 2 años',
        'Entre 2 y 4 años',
        'Más de 4 años',
      ],
      icono: Icons.arrow_upward_outlined,
    ),
    _PreguntaClinica(
      id: 'Q42',
      modulo: 'Bloque 6: Antecedentes de nacimiento y desarrollo',
      pregunta: 'Diferencia de edad con el hermano nacido DESPUÉS que usted',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'No tengo hermanos menores',
        'Menos de 2 años',
        'Entre 2 y 4 años',
        'Más de 4 años',
      ],
      icono: Icons.arrow_downward_outlined,
    ),
    _PreguntaClinica(
      id: 'Q43',
      modulo: 'Bloque 6: Antecedentes de nacimiento y desarrollo',
      pregunta: '¿Usted nació de un embarazo único o múltiple?',
      tipo: _RespuestaTipo.unica,
      opciones: ['Embarazo único', 'Mellizo(a)', 'Gemelo(a)', 'Otro'],
      icono: Icons.child_friendly_outlined,
    ),
    _PreguntaClinica(
      id: 'Q44',
      modulo: 'Bloque 6: Antecedentes de nacimiento y desarrollo',
      pregunta: 'Vía de nacimiento',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Parto normal en hospital',
        'Parto normal en casa u otro lugar',
        'Cesárea',
        'No lo sé',
      ],
      icono: Icons.pregnant_woman_outlined,
    ),
    _PreguntaClinica(
      id: 'Q45',
      modulo: 'Bloque 6: Antecedentes de nacimiento y desarrollo',
      pregunta: 'Tiempo de gestación al nacer',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'A tiempo (A término)',
        'Prematuro (Antes de tiempo)',
        'Postérmino (Después de tiempo)',
        'No lo sé',
      ],
      icono: Icons.hourglass_bottom_outlined,
    ),
    _PreguntaClinica(
      id: 'Q46',
      modulo: 'Bloque 6: Antecedentes de nacimiento y desarrollo',
      pregunta:
          '¿Durante sus primeros meses de vida, recibió leche de fórmula (de tarro)?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'No, solo lactancia materna exclusiva',
        'Sí, combinada con lactancia materna',
        'Sí, exclusivamente fórmula',
        'No lo sé',
      ],
      icono: Icons.baby_changing_station_outlined,
    ),
    _PreguntaClinica(
      id: 'Q47',
      modulo: 'Bloque 6: Antecedentes de nacimiento y desarrollo',
      pregunta:
          'Describa si hizo algún tratamiento médico o padeció alguna enfermedad de importancia durante su infancia',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      icono: Icons.child_care_outlined,
    ),
    _PreguntaClinica(
      id: 'Q48',
      modulo: 'Bloque 6: Antecedentes de nacimiento y desarrollo',
      pregunta:
          '¿Cuando su mamá estuvo embarazada de usted, tuvo alguna enfermedad?',
      tipo: _RespuestaTipo.texto,
      multilinea: true,
      ayuda: 'Especifique cuál si lo sabe.',
      icono: Icons.pregnant_woman_outlined,
    ),

    // BLOQUE 7: SALUD GINECO-OBSTETRICA (oculto si el paciente es masculino)
    _PreguntaClinica(
      id: 'Q49',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: '¿A qué edad tuvo su primera menstruación (Menarquia)?',
      tipo: _RespuestaTipo.numero,
      icono: Icons.female_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q50',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: '¿A qué edad tuvo su última menstruación?',
      tipo: _RespuestaTipo.texto,
      ayuda:
          "Indique la edad o escriba 'No aplica' si aún continúa menstruando.",
      icono: Icons.female_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q51',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'Fecha de inicio de su última menstruación (FUM)',
      tipo: _RespuestaTipo.fecha,
      icono: Icons.event_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q52',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'Frecuencia habitual de sus ciclos menstruales',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Regular (Cada 21 a 35 días)',
        'Irregular (Menos de 20 días)',
        'Irregular (Más de 35 días)',
        'No aplica (Menopausia / Amenorrea)',
      ],
      icono: Icons.calendar_month_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q53',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'Duración promedio del sangrado',
      tipo: _RespuestaTipo.unica,
      opciones: ['1 a 2 días', '3 a 7 días', 'Más de 7 días', 'No aplica'],
      icono: Icons.water_drop_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q54',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'El dolor durante su menstruación habitualmente es',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'No presenta dolor o es leve',
        'Doloroso (interfiere con sus actividades diarias)',
        'No aplica',
      ],
      icono: Icons.sentiment_dissatisfied_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q55a',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'Historial obstétrico: número de Embarazos totales',
      tipo: _RespuestaTipo.numero,
      ayuda: "Escriba '0' si no aplica.",
      icono: Icons.pregnant_woman_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q55b',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'Historial obstétrico: número de Partos vaginales',
      tipo: _RespuestaTipo.numero,
      ayuda: "Escriba '0' si no aplica.",
      icono: Icons.pregnant_woman_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q55c',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'Historial obstétrico: número de Cesáreas',
      tipo: _RespuestaTipo.numero,
      ayuda: "Escriba '0' si no aplica.",
      icono: Icons.medical_services_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q55d',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta:
          'Historial obstétrico: número de Abortos, pérdidas o fracasos gestacionales',
      tipo: _RespuestaTipo.numero,
      ayuda: "Escriba '0' si no aplica.",
      icono: Icons.medical_services_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q56',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta:
          '¿Qué métodos anticonceptivos utiliza actualmente o ha utilizado con frecuencia?',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Ninguno',
        'Preservativo (Condón masculino/femenino)',
        'Pastillas anticonceptivas diarias',
        'Anticonceptivo de emergencia (Pastilla del día después)',
        'Inyectables, parches o implantes subcutáneos',
        'Dispositivo intrauterino (T de cobre / Hormonal)',
        'Ligadura de trompas / Vasectomía',
        'Métodos naturales (Ritmo / Coito interrumpido)',
      ],
      icono: Icons.health_and_safety_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q57',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'Fecha de su último Papanicolau (Citología)',
      tipo: _RespuestaTipo.fecha,
      ayuda:
          'Si nunca se ha realizado uno, puede omitir esta pregunta o indicar una fecha aproximada.',
      icono: Icons.fact_check_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q58',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'Resultado del último Papanicolau',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Normal / Sin alteraciones',
        'Alterado / Infección / Requiere seguimiento',
        'No lo sé / Pendiente de resultado',
        'Nunca me lo he realizado',
      ],
      icono: Icons.fact_check_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q59',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'Fecha de su último control de mamas (Ecografía o Mamografía)',
      tipo: _RespuestaTipo.fecha,
      icono: Icons.medical_information_outlined,
      ocultarSiMasculino: true,
    ),
    _PreguntaClinica(
      id: 'Q60',
      modulo: 'Bloque 7: Salud gineco-obstétrica',
      pregunta: 'Resultado del control de mamas',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Normal / Sin alteraciones',
        'Alterado / Requiere seguimiento u otra evaluación',
        'No lo sé / Pendiente de resultado',
        'Nunca me lo he realizado',
      ],
      icono: Icons.medical_information_outlined,
      ocultarSiMasculino: true,
    ),

    // BLOQUE 8: SALUD UROLOGICA Y URINARIA
    _PreguntaClinica(
      id: 'Q61',
      modulo: 'Bloque 8: Salud urológica y urinaria',
      pregunta:
          '¿Cómo describe la fuerza y forma del chorro de su orina actual en comparación con cuando tenía menos de 30 años?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'Normal (Sin cambios, fuerte y continuo)',
        'Ha disminuido la fuerza o el calibre del chorro',
        'Chorro intermitente (se corta y vuelve a empezar)',
        'Chorro disperso o bífido (se abre en dos direcciones)',
      ],
      icono: Icons.water_drop_outlined,
    ),
    _PreguntaClinica(
      id: 'Q62',
      modulo: 'Bloque 8: Salud urológica y urinaria',
      pregunta:
          'Marque si presenta actualmente alguno de los siguientes síntomas urinarios',
      tipo: _RespuestaTipo.multiple,
      opciones: [
        'Dolor o ardor al orinar',
        'Goteo involuntario de orina justo después de terminar',
        'Sensación de no vaciar por completo la vejiga (Tenesmo)',
        'Ninguno de los anteriores',
      ],
      icono: Icons.report_problem_outlined,
    ),
    _PreguntaClinica(
      id: 'Q63',
      modulo: 'Bloque 8: Salud urológica y urinaria',
      pregunta: '¿Presenta alguna dificultad para lograr o mantener una erección?',
      tipo: _RespuestaTipo.unica,
      opciones: [
        'No presenta dificultades',
        'Sí, ocasionalmente',
        'Sí, frecuentemente',
        'Prefiero no responder',
      ],
      icono: Icons.male_outlined,
      soloMasculino: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarModoAudible();
      _cargarBorrador().then((_) {
        if (mounted) {
          context.read<ChatbotBloc>().add(const VerificarEstadoEvent());
        }
      });
    });
  }

  Future<void> _cargarModoAudible() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = prefs.getBool(_modoAudibleKey) ?? true;
    if (mounted) setState(() => _modoAudible = valor);
  }

  Future<void> _toggleModoAudible() async {
    final nuevoValor = !_modoAudible;
    setState(() => _modoAudible = nuevoValor);
    if (!nuevoValor) await _detener();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modoAudibleKey, nuevoValor);
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
    if (!_modoAudible || !_enModoFormulario) return;
    final texto = _preguntas[_preguntaActual].pregunta;
    _leer(texto);
  }

  Future<void> _cargarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    final resumen = prefs.getStringList(_borradorResumenKey) ?? [];
    final pendientes = prefs.getStringList(_borradorPendientesKey) ?? [];
    if (resumen.isEmpty && pendientes.isEmpty) return;
    final preguntaGuardada = prefs.getInt(_borradorPreguntaKey) ?? 0;

    final respuestasJson = prefs.getString(_borradorRespuestasKey);

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
      if (respuestasJson != null) {
        final decoded = jsonDecode(respuestasJson) as Map<String, dynamic>;
        _respuestasPorId
          ..clear()
          ..addAll(decoded.map((k, v) => MapEntry(k, v as String)));
      }
      _borradorRestaurado = true;
    });
  }

  Future<void> _guardarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_borradorPreguntaKey, _preguntaActual);
    await prefs.setBool(_borradorCompletadoKey, _flujoCompletado);
    await prefs.setStringList(_borradorPendientesKey, _respuestasAcumuladas);
    await prefs.setStringList(_borradorResumenKey, _resumenRespuestas);
    await prefs.setString(_borradorRespuestasKey, jsonEncode(_respuestasPorId));
  }

  Future<void> _limpiarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_borradorPreguntaKey);
    await prefs.remove(_borradorCompletadoKey);
    await prefs.remove(_borradorPendientesKey);
    await prefs.remove(_borradorResumenKey);
    await prefs.remove(_borradorRespuestasKey);
  }

  bool get _enModoFormulario {
    if (_esNuevo == null) return false;
    if (_esNuevo!) return !_flujoCompletado;
    return _mostrarFormulario && !_flujoCompletado;
  }

  // Determina si una pregunta debe ocultarse: ya viene del perfil, no aplica
  // por genero, o depende de una respuesta previa que no habilita mostrarla.
  bool _debeSaltarse(_PreguntaClinica p) {
    if (_idsAutoCompletados.contains(p.id)) return true;
    if (p.ocultarSiMasculino && _generoPaciente == 'M') return true;
    if (p.soloMasculino && _generoPaciente != 'M') return true;
    if (p.dependeDeId != null) {
      final respuesta = _respuestasPorId[p.dependeDeId];
      if (respuesta == null || p.mostrarSi == null) return true;
      if (!p.mostrarSi!(respuesta)) return true;
    }
    return false;
  }

  // Avanza a la siguiente pregunta visible; si no hay más, completa el flujo
  void _avanzarPregunta() {
    int siguiente = _preguntaActual + 1;
    while (siguiente < _preguntas.length &&
        _debeSaltarse(_preguntas[siguiente])) {
      siguiente++;
    }
    if (siguiente < _preguntas.length) {
      _preguntaActual = siguiente;
    } else {
      _flujoCompletado = true;
      _mostrarFormulario = false;
    }
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

    _respuestasPorId[pregunta.id] = respuesta;
    _respuestasAcumuladas.add(texto);
    _resumenRespuestas.add(texto);
    _respuestaController.clear();
    _seleccionMultiple.clear();
    _fechaSeleccionada = null;
    _horaSeleccionada = null;

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
        normalizada == 'ninguno de los anteriores' ||
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
          final autoCompletados = <String>{};

          if (p.nombreCompleto != null && p.nombreCompleto!.isNotEmpty) {
            partes.add('- Nombre completo: ${p.nombreCompleto}');
            autoCompletados.add('Q1');
          }
          if (p.edad != null) {
            partes.add('- Edad: ${p.edad} años');
            autoCompletados.add('Q2');
          }
          if (p.fechaNacimiento != null) {
            final fn = p.fechaNacimiento!;
            partes.add(
              '- Fecha de nacimiento: ${fn.day.toString().padLeft(2, '0')}/${fn.month.toString().padLeft(2, '0')}/${fn.year}',
            );
            autoCompletados.add('Q3');
          }
          if (p.telefono != null && p.telefono!.isNotEmpty) {
            partes.add('- Teléfono: ${p.telefono}');
            autoCompletados.add('Q7');
          }

          setState(() {
            _esNuevo = state.esNuevo;
            _generoPaciente = p.genero;
            _idsAutoCompletados.addAll(autoCompletados);
            if (!_borradorRestaurado) {
              int primero = 0;
              while (primero < _preguntas.length &&
                  _debeSaltarse(_preguntas[primero])) {
                primero++;
              }
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
          if (_modoAudible && ultimo != null && !ultimo.esUsuario) {
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
              IconButton(
                icon: Icon(
                  _modoAudible
                      ? Icons.volume_up_outlined
                      : Icons.volume_off_outlined,
                ),
                tooltip: _modoAudible
                    ? 'Desactivar modo audible'
                    : 'Activar modo audible',
                onPressed: _toggleModoAudible,
              ),
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
        return _buildRespuestaTexto(disabled, multilinea: pregunta.multilinea);
      case _RespuestaTipo.numero:
        return _buildRespuestaNumero(disabled);
      case _RespuestaTipo.fecha:
        return _buildRespuestaFecha(disabled);
      case _RespuestaTipo.hora:
        return _buildRespuestaHora(disabled);
      case _RespuestaTipo.multiple:
        return _buildSeleccionMultiple(pregunta.opciones, disabled);
      case _RespuestaTipo.unica:
        return _buildSeleccionUnica(pregunta.opciones, disabled);
    }
  }

  Widget _buildRespuestaTexto(bool disabled, {bool multilinea = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _respuestaController,
            enabled: !disabled,
            minLines: 1,
            maxLines: multilinea ? 6 : 2,
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

  Widget _buildRespuestaNumero(bool disabled) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _respuestaController,
            enabled: !disabled,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Escribe un número',
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
                  final valor = int.tryParse(_respuestaController.text.trim());
                  if (valor != null && valor >= 0) {
                    _enviarRespuestaGuiada(valor.toString());
                  }
                },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Enviar'),
        ),
      ],
    );
  }

  Widget _buildRespuestaFecha(bool disabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: disabled
              ? null
              : () async {
                  final ahora = DateTime.now();
                  final seleccionada = await showDatePicker(
                    context: context,
                    initialDate: _fechaSeleccionada ?? DateTime(ahora.year - 20),
                    firstDate: DateTime(1900),
                    lastDate: ahora,
                  );
                  if (seleccionada != null) {
                    setState(() => _fechaSeleccionada = seleccionada);
                  }
                },
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(
            _fechaSeleccionada == null
                ? 'Seleccionar fecha'
                : DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: disabled || _fechaSeleccionada == null
              ? null
              : () => _enviarRespuestaGuiada(
                  DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!),
                ),
          icon: const Icon(Icons.check),
          label: const Text('Confirmar fecha'),
        ),
      ],
    );
  }

  Widget _buildRespuestaHora(bool disabled) {
    String formatear(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: disabled
              ? null
              : () async {
                  final seleccionada = await showTimePicker(
                    context: context,
                    initialTime: _horaSeleccionada ?? TimeOfDay.now(),
                  );
                  if (seleccionada != null) {
                    setState(() => _horaSeleccionada = seleccionada);
                  }
                },
          icon: const Icon(Icons.access_time_outlined),
          label: Text(
            _horaSeleccionada == null
                ? 'Seleccionar hora'
                : formatear(_horaSeleccionada!),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: disabled || _horaSeleccionada == null
              ? null
              : () => _enviarRespuestaGuiada(formatear(_horaSeleccionada!)),
          icon: const Icon(Icons.check),
          label: const Text('Confirmar hora'),
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
