import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_event.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_state.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ReservarCitaAsistentePage extends StatefulWidget {
  final int ciudadId;
  final String ciudadNombre;

  const ReservarCitaAsistentePage({
    super.key,
    required this.ciudadId,
    required this.ciudadNombre,
  });

  @override
  State<ReservarCitaAsistentePage> createState() =>
      _ReservarCitaAsistentePageState();
}

class _ReservarCitaAsistentePageState extends State<ReservarCitaAsistentePage> {
  List<dynamic> _pacientes = [];
  dynamic _pacienteSeleccionado;
  List<Servicio> _servicios = [];
  Servicio? _servicioSeleccionado;
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  List<String> _horasDisponibles = [];
  Set<DateTime> _diasDisponibles = {};
  bool _cargandoPacientes = false;
  bool _cargandoCalendario = false;
  bool _cargandoHoras = false;
  bool _usarPacienteNuevo = false;
  bool _creandoPaciente = false;
  final _notasController = TextEditingController();
  final _pacienteController = TextEditingController();
  final _nuevoPacienteNombreController = TextEditingController();
  final _nuevoPacienteTelefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CitaBloc>().add(CargarServiciosEvent());
    _cargarPacientes();
    _cargarDiasDisponibles();
  }

  @override
  void dispose() {
    _notasController.dispose();
    _pacienteController.dispose();
    _nuevoPacienteNombreController.dispose();
    _nuevoPacienteTelefonoController.dispose();
    super.dispose();
  }

  Future<void> _cargarPacientes() async {
    if (!mounted) return;
    setState(() => _cargandoPacientes = true);
    try {
      // Asistente solo ve pacientes de su ciudad
      final response = await ApiClientProvider.instance.dio.get('/pacientes');
      if (!mounted) return;
      setState(() {
        _pacientes = (response.data as List)
            .where((p) => p['usuario']['ciudad']?['id'] == widget.ciudadId)
            .toList();
        _cargandoPacientes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoPacientes = false);
    }
  }

  Future<void> _cargarDiasDisponibles() async {
    if (!mounted) return;
    setState(() => _cargandoCalendario = true);
    try {
      final diasDisponibles = <DateTime>{};
      final ahora = DateTime.now();

      for (int i = 1; i <= 60; i++) {
        final dia = ahora.add(Duration(days: i));
        try {
          final response = await ApiClientProvider.instance.dio.get(
            '/agenda/disponibilidad',
            queryParameters: {
              'ciudadId': widget.ciudadId,
              'fecha': DateFormat('yyyy-MM-dd').format(dia),
            },
          );
          final horas = List<String>.from(
            response.data['horasDisponibles'] ?? [],
          );
          if (horas.isNotEmpty) {
            diasDisponibles.add(DateTime(dia.year, dia.month, dia.day));
          }
        } catch (e) {
          debugPrint('Error verificando día: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _diasDisponibles = diasDisponibles;
        _cargandoCalendario = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoCalendario = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Nueva Cita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<CitaBloc, CitaState>(
        listener: (context, state) {
          if (!mounted) return;
          if (state is ServiciosCargados) {
            setState(() => _servicios = state.servicios);
          }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ciudad fija (no editable)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B5C8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF00B5C8).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_city_outlined,
                      color: Color(0xFF00B5C8),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu ciudad',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          widget.ciudadNombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00B5C8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Paciente (solo de su ciudad)
              const Text(
                'Paciente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.person_search_outlined),
                    label: Text('Existente'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.person_add_alt_1_outlined),
                    label: Text('Nuevo'),
                  ),
                ],
                selected: {_usarPacienteNuevo},
                onSelectionChanged: (selection) {
                  setState(() {
                    _usarPacienteNuevo = selection.first;
                    _pacienteSeleccionado = null;
                    _pacienteController.clear();
                  });
                },
                style: ButtonStyle(
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
                ),
              ),
              const SizedBox(height: 12),
              _cargandoPacientes
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B5C8),
                      ),
                    )
                  : _usarPacienteNuevo
                  ? _buildPacienteNuevoForm()
                  : TypeAheadField(
                      controller: _pacienteController,
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Buscar paciente...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF00B5C8),
                            ),
                            suffixIcon: _pacienteSeleccionado != null
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF8DC63F),
                                  )
                                : null,
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
                          ),
                        );
                      },
                      suggestionsCallback: (search) {
                        if (search.isEmpty) return _pacientes;
                        return _pacientes.where((p) {
                          final nombre = _nombrePaciente(p).toLowerCase();
                          final ci = (p['ci'] ?? '').toString().toLowerCase();
                          final telefono = (p['telefono'] ?? '')
                              .toString()
                              .toLowerCase();
                          final query = search.toLowerCase();
                          return nombre.contains(query) ||
                              ci.contains(query) ||
                              telefono.contains(query);
                        }).toList();
                      },
                      itemBuilder: (context, paciente) {
                        final nombre = _nombrePaciente(paciente);
                        final ci = (paciente['ci'] ?? '').toString();
                        final telefono = (paciente['telefono'] ?? '')
                            .toString();
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF00B5C8),
                            child: Text(
                              nombre.isNotEmpty
                                  ? nombre[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            ci.isNotEmpty
                                ? 'CI: $ci'
                                : telefono.isNotEmpty
                                ? 'Teléfono: $telefono'
                                : 'Paciente provisional',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      onSelected: (paciente) {
                        setState(() {
                          _pacienteSeleccionado = paciente;
                          _pacienteController.text = _nombrePaciente(paciente);
                        });
                      },
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No se encontraron pacientes',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),

              // Servicio
              const Text(
                'Servicio',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
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

              // Calendario
              const Text(
                'Fecha disponible',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              _cargandoCalendario
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Color(0xFF00B5C8)),
                          SizedBox(height: 8),
                          Text(
                            'Cargando disponibilidad...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TableCalendar(
                        locale: 'es_ES',
                        firstDay: DateTime.now().add(const Duration(days: 1)),
                        lastDay: DateTime.now().add(const Duration(days: 60)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_fechaSeleccionada, day),
                        enabledDayPredicate: (day) {
                          final normalDay = DateTime(
                            day.year,
                            day.month,
                            day.day,
                          );
                          return _diasDisponibles.contains(normalDay);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _fechaSeleccionada = selectedDay;
                            _focusedDay = focusedDay;
                            _horaSeleccionada = null;
                            _horasDisponibles = [];
                            _cargandoHoras = true;
                          });
                          context.read<CitaBloc>().add(
                            CargarDisponibilidadEvent(
                              ciudadId: widget.ciudadId,
                              fecha: DateFormat(
                                'yyyy-MM-dd',
                              ).format(selectedDay),
                            ),
                          );
                        },
                        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final normalDay = DateTime(
                              day.year,
                              day.month,
                              day.day,
                            );
                            if (_diasDisponibles.contains(normalDay)) {
                              return Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF8DC63F,
                                  ).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF8DC63F),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                      color: Color(0xFF8DC63F),
                                      fontWeight: FontWeight.bold,
                                    ),
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
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Color(0xFF00B5C8),
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Color(0xFF00B5C8),
                          ),
                        ),
                      ),
                    ),

              // Horas
              if (_fechaSeleccionada != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Hora disponible',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B5C8),
                  ),
                ),
                const SizedBox(height: 8),
                if (_cargandoHoras)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
                  )
                else if (_horasDisponibles.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'No hay horas disponibles',
                      style: TextStyle(color: Colors.orange),
                    ),
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

              const SizedBox(height: 16),
              const Text(
                'Notas (opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
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

              BlocBuilder<CitaBloc, CitaState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is CitaLoading || _creandoPaciente
                          ? null
                          : () async {
                              if (_servicioSeleccionado == null ||
                                  _fechaSeleccionada == null ||
                                  _horaSeleccionada == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Completa todos los campos requeridos',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              final pacienteId = await _obtenerPacienteId();
                              if (pacienteId == null) return;

                              context.read<CitaBloc>().add(
                                ReservarCitaEvent(
                                  fecha: DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(_fechaSeleccionada!),
                                  hora: _horaSeleccionada!,
                                  servicioId: _servicioSeleccionado!.id,
                                  pacienteId: pacienteId,
                                  ciudadId: widget.ciudadId,
                                  notas: _notasController.text.trim().isEmpty
                                      ? null
                                      : _notasController.text.trim(),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DC63F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state is CitaLoading
                          || _creandoPaciente
                          ? const CircularProgressIndicator(color: Colors.white)
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
    );
  }

  Widget _buildPacienteNuevoForm() {
    return Column(
      children: [
        TextField(
          controller: _nuevoPacienteNombreController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nombre del paciente',
            hintText: 'Ej. María Pérez',
            prefixIcon: const Icon(
              Icons.person_add_alt_1_outlined,
              color: Color(0xFF00B5C8),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00B5C8), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nuevoPacienteTelefonoController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Teléfono',
            hintText: 'Número de contacto',
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: Color(0xFF00B5C8),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00B5C8), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<int?> _obtenerPacienteId() async {
    if (!_usarPacienteNuevo) {
      final pacienteId = _intValue(_pacienteSeleccionado?['id']);
      if (pacienteId == null) {
        _mostrarMensaje('Selecciona un paciente');
      }
      return pacienteId;
    }

    return _crearPacienteProvisional();
  }

  Future<int?> _crearPacienteProvisional() async {
    final nombreCompleto = _nuevoPacienteNombreController.text.trim();
    final telefono = _nuevoPacienteTelefonoController.text.trim();

    if (nombreCompleto.isEmpty || telefono.isEmpty) {
      _mostrarMensaje('Ingresa nombre y teléfono del paciente nuevo');
      return null;
    }

    setState(() => _creandoPaciente = true);
    try {
      final response = await ApiClientProvider.instance.dio.post(
        '/pacientes/provisional',
        data: {
          'nombre': nombreCompleto,
          'nombreCompleto': nombreCompleto,
          'telefono': telefono,
          'ciudadId': widget.ciudadId,
          'provisional': true,
          'perfilCompleto': false,
        },
      );

      final paciente = _extraerPaciente(response.data);
      final pacienteId = _intValue(paciente?['id']);
      if (paciente == null || pacienteId == null) {
        _mostrarMensaje('No se pudo obtener el paciente creado');
        return null;
      }

      if (!mounted) return null;
      setState(() {
        _pacienteSeleccionado = paciente;
        _pacientes = [paciente, ..._pacientes];
        _usarPacienteNuevo = false;
        _pacienteController.text = _nombrePaciente(paciente);
      });
      _mostrarMensaje('Paciente provisional creado', esError: false);
      return pacienteId;
    } catch (e) {
      _mostrarMensaje(
        'No se pudo crear el paciente provisional. Verifica que el backend tenga /pacientes/provisional.',
      );
      return null;
    } finally {
      if (mounted) {
        setState(() => _creandoPaciente = false);
      }
    }
  }

  Map<String, dynamic>? _extraerPaciente(dynamic data) {
    if (data is Map<String, dynamic>) {
      final paciente = data['paciente'];
      if (paciente is Map<String, dynamic>) return paciente;
      return data;
    }
    return null;
  }

  String _nombrePaciente(dynamic paciente) {
    final usuario = paciente?['usuario'];
    if (usuario is Map) {
      return '${usuario['nombre'] ?? ''} ${usuario['apellido'] ?? ''}'.trim();
    }
    return paciente?['nombreCompleto']?.toString() ?? 'Paciente provisional';
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  void _mostrarMensaje(String mensaje, {bool esError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.orange : Colors.green,
      ),
    );
  }
}
