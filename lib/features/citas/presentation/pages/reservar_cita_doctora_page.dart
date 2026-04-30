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

class ReservarCitaDoctoraPage extends StatefulWidget {
  const ReservarCitaDoctoraPage({super.key});

  @override
  State<ReservarCitaDoctoraPage> createState() =>
      _ReservarCitaDoctoraPageState();
}

class _ReservarCitaDoctoraPageState extends State<ReservarCitaDoctoraPage> {
  List<dynamic> _pacientes = [];
  List<dynamic> _ciudades = [];
  dynamic _pacienteSeleccionado;
  dynamic _ciudadSeleccionada;
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
  final _notasController = TextEditingController();
  final _pacienteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CitaBloc>().add(CargarServiciosEvent());
    _cargarPacientesYCiudades();
  }

  @override
  void dispose() {
    _notasController.dispose();
    _pacienteController.dispose();
    super.dispose();
  }

  Future<void> _cargarPacientesYCiudades() async {
    setState(() => _cargandoPacientes = true);
    try {
      final resPacientes = await ApiClientProvider.instance.dio.get(
        '/pacientes',
      );
      final resCiudades = await ApiClientProvider.instance.dio.get('/ciudades');
      setState(() {
        _pacientes = resPacientes.data;
        _ciudades = resCiudades.data;
        _cargandoPacientes = false;
      });
    } catch (e) {
      setState(() => _cargandoPacientes = false);
    }
  }

  Future<void> _cargarDiasDisponibles() async {
    if (_ciudadSeleccionada == null) return;
    setState(() {
      _cargandoCalendario = true;
      _diasDisponibles = {};
      _fechaSeleccionada = null;
      _horaSeleccionada = null;
      _horasDisponibles = [];
    });

    try {
      final ciudadId = _ciudadSeleccionada['id'];
      final diasDisponibles = <DateTime>{};
      final ahora = DateTime.now();

      for (int i = 1; i <= 60; i++) {
        final dia = ahora.add(Duration(days: i));
        try {
          final response = await ApiClientProvider.instance.dio.get(
            '/agenda/disponibilidad',
            queryParameters: {
              'ciudadId': ciudadId,
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

      setState(() {
        _diasDisponibles = diasDisponibles;
        _cargandoCalendario = false;
      });
    } catch (e) {
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
              // Paciente
              const Text(
                'Paciente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              _cargandoPacientes
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B5C8),
                      ),
                    )
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
                          final nombre =
                              '${p['usuario']['nombre']} ${p['usuario']['apellido']}'
                                  .toLowerCase();
                          final ci = p['ci'].toString().toLowerCase();
                          final query = search.toLowerCase();
                          return nombre.contains(query) || ci.contains(query);
                        }).toList();
                      },
                      itemBuilder: (context, paciente) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF00B5C8),
                            child: Text(
                              paciente['usuario']['nombre'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            '${paciente['usuario']['nombre']} ${paciente['usuario']['apellido']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'CI: ${paciente['ci']} • ${paciente['usuario']['ciudad']?['nombreCiudad'] ?? ''}',
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
                          _pacienteController.text =
                              '${paciente['usuario']['nombre']} ${paciente['usuario']['apellido']}';
                          if (paciente['usuario']['ciudad'] != null) {
                            _ciudadSeleccionada = _ciudades.firstWhere(
                              (c) =>
                                  c['id'] ==
                                  paciente['usuario']['ciudad']['id'],
                              orElse: () => null,
                            );
                            _cargarDiasDisponibles();
                          }
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

              // Ciudad
              const Text(
                'Ciudad',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: 'Seleccionar ciudad',
                value: _ciudadSeleccionada,
                items: _ciudades,
                label: (c) => c['nombreCiudad'],
                onChanged: (value) {
                  setState(() => _ciudadSeleccionada = value);
                  _cargarDiasDisponibles();
                },
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
              _ciudadSeleccionada == null
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Selecciona una ciudad primero',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : _cargandoCalendario
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
                  : _buildCalendario(),
              const SizedBox(height: 16),

              // Horas
              if (_fechaSeleccionada != null) _buildHoras(),
              const SizedBox(height: 16),

              // Notas
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

              // Botón
              BlocBuilder<CitaBloc, CitaState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is CitaLoading
                          ? null
                          : () {
                              if (_pacienteSeleccionado == null ||
                                  _ciudadSeleccionada == null ||
                                  _servicioSeleccionado == null ||
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
                              context.read<CitaBloc>().add(
                                ReservarCitaEvent(
                                  fecha: DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(_fechaSeleccionada!),
                                  hora: _horaSeleccionada!,
                                  servicioId: _servicioSeleccionado!.id,
                                  pacienteId: _pacienteSeleccionado['id'],
                                  ciudadId: _ciudadSeleccionada['id'],
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

  Widget _buildDropdown({
    required String hint,
    required dynamic value,
    required List<dynamic> items,
    required String Function(dynamic) label,
    required Function(dynamic) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          isExpanded: true,
          hint: Text(hint),
          value: value,
          items: items
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(label(item))),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

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
          });
          context.read<CitaBloc>().add(
            CargarDisponibilidadEvent(
              ciudadId: _ciudadSeleccionada['id'],
              fecha: DateFormat('yyyy-MM-dd').format(selectedDay),
            ),
          );
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final normalDay = DateTime(day.year, day.month, day.day);
            if (_diasDisponibles.contains(normalDay)) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8DC63F).withOpacity(0.2),
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
          disabledBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            );
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
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF00B5C8)),
        ),
      ),
    );
  }

  Widget _buildHoras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }
}
