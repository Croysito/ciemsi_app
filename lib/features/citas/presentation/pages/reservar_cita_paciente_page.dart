import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/agenda/data/models/agenda_model.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_event.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_state.dart';
import 'package:ciemsi_app/features/servicios/data/models/servicio_model.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

class ReservarCitaPacientePage extends StatefulWidget {
  const ReservarCitaPacientePage({super.key});

  @override
  State<ReservarCitaPacientePage> createState() =>
      _ReservarCitaPacientePageState();
}

class _ReservarCitaPacientePageState extends State<ReservarCitaPacientePage> {
  int? _ciudadId;

  // Agenda dinámica
  List<AgendaModel> _agendasCiudad = [];
  String? _rolCreadorSeleccionado; // 'Doctora' | 'Asistente'
  int? _agendaSeleccionadaId;
  bool _tieneAgendaDoctora = false;
  bool _tieneAgendaAsistente = false;
  bool _sinAgendasEnCiudad = false;
  Set<DateTime> _diasDoctora = {};
  Set<DateTime> _diasAsistente = {};

  // Servicios dinámicos (cargados según rolCreador de la agenda)
  List<Servicio> _servicios = [];
  Servicio? _servicioSeleccionado;
  bool _cargandoServicios = false;

  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  List<String> _horasDisponibles = [];
  Set<DateTime> _diasDisponibles = {};
  bool _cargandoCalendario = false;
  bool _cargandoHoras = false;
  final _notasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarCiudadPaciente();
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _cargarCiudadPaciente() async {
    try {
      final response = await ApiClientProvider.instance.dio.get(
        '/pacientes/mi-perfil',
      );
      final ciudadId = response.data['usuario']?['ciudad']?['id'];
      if (ciudadId != null) {
        setState(() => _ciudadId = ciudadId);
        await _cargarDiasDisponibles();
      }
    } catch (e) {
      debugPrint('Error obteniendo ciudad del paciente: $e');
    }
  }

  Future<DateTime?> _verificarDia(DateTime dia) async {
    try {
      final response = await ApiClientProvider.instance.dio.get(
        '/agenda/disponibilidad',
        queryParameters: {
          'ciudadId': _ciudadId,
          'fecha': DateFormat('yyyy-MM-dd').format(dia),
        },
      );
      final horas =
          List<String>.from(response.data['horasDisponibles'] ?? []);
      if (horas.isNotEmpty) return DateTime(dia.year, dia.month, dia.day);
    } catch (_) {}
    return null;
  }

  Future<void> _cargarDiasDisponibles() async {
    if (_ciudadId == null) return;
    setState(() {
      _cargandoCalendario = true;
      _diasDisponibles = {};
      _fechaSeleccionada = null;
      _horaSeleccionada = null;
      _horasDisponibles = [];
      _rolCreadorSeleccionado = null;
      _agendaSeleccionadaId = null;
      _tieneAgendaDoctora = false;
      _tieneAgendaAsistente = false;
      _sinAgendasEnCiudad = false;
      _servicios = [];
      _servicioSeleccionado = null;
    });
    try {
      final ahora = DateTime.now();

      // Obtiene agendas y disponibilidad en paralelo
      final agendasRequest = ApiClientProvider.instance.dio.get(
        '/agenda',
        queryParameters: {'ciudadId': _ciudadId},
      );
      final diasFutures = List.generate(
        60,
        (i) => _verificarDia(ahora.add(Duration(days: i + 1))),
      );
      final diasRequest = Future.wait(diasFutures);

      final agendasResponse = await agendasRequest;
      final diasResults = await diasRequest;

      if (!mounted) return;

      final List<AgendaModel> agendas = [];
      for (final a in (agendasResponse.data as List)) {
        try {
          final agenda = AgendaModel.fromJson(a as Map<String, dynamic>);
          if (agenda.estado) agendas.add(agenda);
        } catch (_) {}
      }

      final disponibles = diasResults.whereType<DateTime>().toSet();
      final diasDoctora = <DateTime>{};
      final diasAsistente = <DateTime>{};
      const nombresDias = ['DOMINGO','LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO'];
      for (final dia in disponibles) {
        for (final agenda in agendas) {
          bool aplica = false;
          if (agenda.diasSemana != null && agenda.diasSemana!.isNotEmpty) {
            aplica = agenda.diasSemana!.contains(nombresDias[dia.weekday % 7]);
          } else if (agenda.fecha != null) {
            aplica = agenda.fecha!.year == dia.year &&
                agenda.fecha!.month == dia.month &&
                agenda.fecha!.day == dia.day;
          }
          if (aplica) {
            if (agenda.rolCreador == 'Doctora') {
              diasDoctora.add(dia);
            } else if (agenda.rolCreador == 'Asistente') {
              diasAsistente.add(dia);
            }
          }
        }
      }

      setState(() {
        _diasDisponibles = disponibles;
        _diasDoctora = diasDoctora;
        _diasAsistente = diasAsistente;
        _agendasCiudad = agendas;
        _sinAgendasEnCiudad = agendas.isEmpty;
        _cargandoCalendario = false;
      });
    } catch (e) {
      setState(() => _cargandoCalendario = false);
    }
  }

  // Detecta qué tipos de agenda existen para el día seleccionado
  void _detectarTiposAgendaParaDia(DateTime dia) {
    const nombresDias = [
      'DOMINGO',
      'LUNES',
      'MARTES',
      'MIERCOLES',
      'JUEVES',
      'VIERNES',
      'SABADO',
    ];
    bool tieneDoctora = false;
    bool tieneAsistente = false;

    for (final agenda in _agendasCiudad) {
      bool aplica = false;
      if (agenda.diasSemana != null && agenda.diasSemana!.isNotEmpty) {
        aplica = agenda.diasSemana!.contains(nombresDias[dia.weekday % 7]);
      } else if (agenda.fecha != null) {
        aplica = agenda.fecha!.year == dia.year &&
            agenda.fecha!.month == dia.month &&
            agenda.fecha!.day == dia.day;
      }
      if (aplica) {
        if (agenda.rolCreador == 'Doctora') {
          tieneDoctora = true;
        } else if (agenda.rolCreador == 'Asistente') {
          tieneAsistente = true;
        }
      }
    }

    setState(() {
      _tieneAgendaDoctora = tieneDoctora;
      _tieneAgendaAsistente = tieneAsistente;
      _servicios = [];
      _servicioSeleccionado = null;
    });

    if (tieneDoctora && !tieneAsistente) {
      _seleccionarRolAgenda('Doctora');
    } else if (!tieneDoctora && tieneAsistente) {
      _seleccionarRolAgenda('Asistente');
    } else {
      setState(() => _rolCreadorSeleccionado = null);
    }
  }

  void _seleccionarRolAgenda(String rol) {
    final agenda = _fechaSeleccionada != null
        ? _encontrarAgendaParaDia(_fechaSeleccionada!, rol)
        : null;
    setState(() {
      _rolCreadorSeleccionado = rol;
      _agendaSeleccionadaId = agenda?.id;
    });
    _cargarServiciosPorRol(rol);
  }

  AgendaModel? _encontrarAgendaParaDia(DateTime dia, String rol) {
    const nombresDias = ['DOMINGO','LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO'];
    for (final agenda in _agendasCiudad) {
      if (agenda.rolCreador != rol) continue;
      bool aplica = false;
      if (agenda.diasSemana != null && agenda.diasSemana!.isNotEmpty) {
        aplica = agenda.diasSemana!.contains(nombresDias[dia.weekday % 7]);
      } else if (agenda.fecha != null) {
        aplica = agenda.fecha!.year == dia.year &&
            agenda.fecha!.month == dia.month &&
            agenda.fecha!.day == dia.day;
      }
      if (aplica) return agenda;
    }
    return null;
  }

  Future<void> _cargarServiciosPorRol(String rol) async {
    setState(() {
      _cargandoServicios = true;
      _servicios = [];
      _servicioSeleccionado = null;
    });

    // Use services embedded in the specific agenda when available
    if (_fechaSeleccionada != null) {
      final agenda = _encontrarAgendaParaDia(_fechaSeleccionada!, rol);
      if (agenda != null &&
          agenda.servicios != null &&
          agenda.servicios!.isNotEmpty) {
        setState(() {
          _servicios = agenda.servicios!;
          _cargandoServicios = false;
        });
        return;
      }
    }

    try {
      final res = await ApiClientProvider.instance.dio.get(
        '/servicios/por-rol',
        queryParameters: {'rol': rol},
      );
      if (!mounted) return;
      setState(() {
        _servicios = (res.data as List)
            .map((s) => ServicioModel.fromJson(s as Map<String, dynamic>))
            .toList();
        _cargandoServicios = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoServicios = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Reservar Cita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<CitaBloc, CitaState>(
        listener: (context, state) {
          if (state is DisponibilidadCargada) {
            setState(() {
              _horasDisponibles = state.horasDisponibles;
              _cargandoHoras = false;
            });
          }
          if (state is CitaReservada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cita reservada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is CitaError) {
            setState(() => _cargandoHoras = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _ciudadId == null
            ? _buildCargandoCiudad()
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Calendario ───────────────────────────────
                    _buildLabel('Fecha disponible'),
                    const SizedBox(height: 8),
                    if (_cargandoCalendario)
                      _buildLoadingState('Cargando disponibilidad...')
                    else if (_sinAgendasEnCiudad)
                      _buildInfoBanner(
                        'No hay agendas disponibles en tu ciudad',
                        Icons.event_busy_outlined,
                        isWarning: true,
                      )
                    else if (_diasDisponibles.isEmpty)
                      _buildInfoBanner(
                        'No hay fechas disponibles en tu ciudad',
                        Icons.calendar_today_outlined,
                        isWarning: true,
                      )
                    else
                      _buildCalendario(),
                    const SizedBox(height: 16),

                    // ── Horas ────────────────────────────────────
                    if (_fechaSeleccionada != null) ...[
                      _buildHoras(),
                      const SizedBox(height: 16),
                    ],

                    // ── Selector tipo de agenda (solo si hay ambos)
                    if (_fechaSeleccionada != null &&
                        _tieneAgendaDoctora &&
                        _tieneAgendaAsistente) ...[
                      _buildLabel('Tipo de consulta'),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'Doctora',
                            icon: Icon(Icons.medical_services_outlined),
                            label: Text('Doctora'),
                          ),
                          ButtonSegment(
                            value: 'Asistente',
                            icon: Icon(Icons.support_agent_outlined),
                            label: Text('Asistente'),
                          ),
                        ],
                        selected: _rolCreadorSeleccionado != null
                            ? {_rolCreadorSeleccionado!}
                            : {},
                        emptySelectionAllowed: true,
                        onSelectionChanged: (selection) {
                          if (selection.isNotEmpty) {
                            _seleccionarRolAgenda(selection.first);
                          }
                        },
                        style: _segmentedStyle(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Servicios (dinámicos según agenda) ───────
                    if (_rolCreadorSeleccionado != null) ...[
                      _buildLabel('Servicio'),
                      const SizedBox(height: 8),
                      if (_cargandoServicios)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00B5C8),
                          ),
                        )
                      else if (_servicios.isEmpty)
                        _buildInfoBanner(
                          'No hay servicios disponibles',
                          Icons.info_outline,
                          isWarning: true,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Servicio>(
                              isExpanded: true,
                              hint: const Text('Seleccionar servicio'),
                              value: _servicioSeleccionado,
                              items: _servicios
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        '${s.nombreServicio} (${s.tiempoMin} min)',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _servicioSeleccionado = value),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],

                    // ── Notas ────────────────────────────────────
                    _buildLabel('Notas (opcional)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notasController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Escribe alguna nota...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Botón ────────────────────────────────────
                    BlocBuilder<CitaBloc, CitaState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state is CitaLoading ? null : _onReservar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8DC63F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: state is CitaLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Reservar Cita',
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
      ),
    );
  }

  void _onReservar() {
    if (_servicioSeleccionado == null ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona fecha, hora y servicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    context.read<CitaBloc>().add(
      ReservarCitaEvent(
        fecha: DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!),
        hora: _horaSeleccionada!,
        servicioId: _servicioSeleccionado!.id,
        agendaId: _agendaSeleccionadaId,
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────

  Widget _buildCargandoCiudad() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: Color(0xFF00B5C8)),
        SizedBox(height: 12),
        Text(
          'Cargando tu información...',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF00B5C8),
    ),
  );

  Widget _buildInfoBanner(
    String text,
    IconData icon, {
    bool isWarning = false,
  }) {
    final color = isWarning ? Colors.orange : Colors.grey;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? Colors.orange.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String text) => Center(
    child: Column(
      children: [
        const CircularProgressIndicator(color: Color(0xFF00B5C8)),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    ),
  );

  ButtonStyle _segmentedStyle() => ButtonStyle(
    visualDensity: VisualDensity.compact,
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.white
          : const Color(0xFF00B5C8),
    ),
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const Color(0xFF00B5C8)
          : Colors.white,
    ),
  );

  Widget _buildCalendario() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TableCalendar(
        locale: 'es_ES',
        firstDay: DateTime.now().add(const Duration(days: 1)),
        lastDay: DateTime.now().add(const Duration(days: 60)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_fechaSeleccionada, day),
        enabledDayPredicate: (day) {
          final normalDay = DateTime(day.year, day.month, day.day);
          return _diasDisponibles.contains(normalDay);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _fechaSeleccionada = selectedDay;
            _focusedDay = focusedDay;
            _horaSeleccionada = null;
            _horasDisponibles = [];
            _cargandoHoras = true;
            _rolCreadorSeleccionado = null;
            _servicios = [];
            _servicioSeleccionado = null;
          });
          _detectarTiposAgendaParaDia(selectedDay);
          context.read<CitaBloc>().add(
            CargarDisponibilidadEvent(
              ciudadId: _ciudadId!,
              fecha: DateFormat('yyyy-MM-dd').format(selectedDay),
            ),
          );
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final normalDay = DateTime(day.year, day.month, day.day);
            final esDoctora = _diasDoctora.contains(normalDay);
            final esAsistente = _diasAsistente.contains(normalDay);
            if (esDoctora || esAsistente) {
              final color = (esDoctora && esAsistente)
                  ? const Color(0xFF7B5EA7)
                  : esDoctora
                  ? const Color(0xFF00B5C8)
                  : const Color(0xFF8DC63F);
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }
            return null;
          },
        ),
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Color(0xFF00B5C8),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: Colors.grey),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF00B5C8),
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF00B5C8)),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Color(0xFF00B5C8),
          ),
        ),
      ),
    );
  }

  Widget _buildHoras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Hora disponible'),
        const SizedBox(height: 8),
        if (_cargandoHoras)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
          )
        else if (_horasDisponibles.isEmpty)
          _buildInfoBanner(
            'No hay horas disponibles para este día',
            Icons.access_time_outlined,
            isWarning: true,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _horasDisponibles.map((hora) {
              final seleccionada = _horaSeleccionada == hora;
              return GestureDetector(
                onTap: () => setState(() => _horaSeleccionada = hora),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: seleccionada
                        ? const Color(0xFF00B5C8)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: seleccionada
                          ? const Color(0xFF00B5C8)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    hora,
                    style: TextStyle(
                      color: seleccionada ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
