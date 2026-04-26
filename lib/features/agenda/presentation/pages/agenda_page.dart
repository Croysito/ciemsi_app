import 'package:ciemsi_app/features/agenda/presentation/pages/crear_agenda.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/agenda/data/models/agenda_model.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  List<AgendaModel> _agendas = [];
  List<Ciudad> _ciudades = [];
  Ciudad? _ciudadSeleccionada;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _cargando = false;

  // Días que tienen agenda configurada
  Set<DateTime> _diasConAgenda = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _cargarCiudades();
  }

  Future<void> _cargarCiudades() async {
    try {
      final response = await ApiClientProvider.instance.dio.get('/ciudades');
      setState(() {
        _ciudades = (response.data as List)
            .map((c) => Ciudad(id: c['id'], nombreCiudad: c['nombreCiudad']))
            .toList();
        if (_ciudades.isNotEmpty) {
          _ciudadSeleccionada = _ciudades.first;
          _cargarAgenda();
        }
      });
    } catch (e) {
      debugPrint('Error cargando ciudades: $e');
    }
  }

  Future<void> _cargarAgenda() async {
    if (_ciudadSeleccionada == null) return;
    setState(() => _cargando = true);
    try {
      final response = await ApiClientProvider.instance.dio.get(
        '/agenda',
        queryParameters: {'ciudadId': _ciudadSeleccionada!.id},
      );
      final agendas = (response.data as List)
          .map((a) => AgendaModel.fromJson(a))
          .toList();

      // Calcular días con agenda para el mes actual y siguiente
      final diasConAgenda = <DateTime>{};
      final ahora = DateTime.now();
      for (int i = 0; i < 60; i++) {
        final dia = ahora.add(Duration(days: i));
        for (final agenda in agendas) {
          if (_agendaAplicaParaDia(agenda, dia)) {
            diasConAgenda.add(DateTime(dia.year, dia.month, dia.day));
          }
        }
      }

      setState(() {
        _agendas = agendas;
        _diasConAgenda = diasConAgenda;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  bool _agendaAplicaParaDia(AgendaModel agenda, DateTime dia) {
    if (agenda.fecha != null) {
      return agenda.fecha!.year == dia.year &&
          agenda.fecha!.month == dia.month &&
          agenda.fecha!.day == dia.day;
    }
    if (agenda.diasSemana != null) {
      final dias = [
        'DOMINGO',
        'LUNES',
        'MARTES',
        'MIERCOLES',
        'JUEVES',
        'VIERNES',
        'SABADO',
      ];
      return agenda.diasSemana!.contains(dias[dia.weekday % 7]);
    }
    return false;
  }

  List<AgendaModel> _agendasDelDia(DateTime dia) {
    return _agendas.where((a) => _agendaAplicaParaDia(a, dia)).toList();
  }

  Future<void> _eliminarAgenda(int id) async {
    try {
      await ApiClientProvider.instance.dio.delete('/agenda/$id');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda eliminada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarAgenda();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Agenda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarAgenda),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8DC63F),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CrearAgendaPage(
                ciudades: _ciudades,
                ciudadInicial: _ciudadSeleccionada,
                fechaInicial: _selectedDay,
              ),
            ),
          );
          _cargarAgenda();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Agenda',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Selector ciudad
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Ciudad>(
                  isExpanded: true,
                  value: _ciudadSeleccionada,
                  items: _ciudades
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.nombreCiudad),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _ciudadSeleccionada = value;
                      _selectedDay = DateTime.now();
                    });
                    _cargarAgenda();
                  },
                ),
              ),
            ),
          ),

          // Calendario
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: TableCalendar(
              locale: 'es_ES',
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final normalDay = DateTime(day.year, day.month, day.day);
                  if (_diasConAgenda.contains(normalDay)) {
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
              ),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF00B5C8),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFF00B5C8),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Colors.white),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Color(0xFF00B5C8),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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

          // Agendas del día seleccionado
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDay!),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00B5C8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B5C8),
                      ),
                    )
                  : Builder(
                      builder: (context) {
                        final agendasDia = _agendasDelDia(_selectedDay!);
                        if (agendasDia.isEmpty) {
                          return const Center(
                            child: Text(
                              'No hay agenda para este día',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: agendasDia.length,
                          itemBuilder: (context, index) {
                            final agenda = agendasDia[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF8DC63F),
                                  child: Icon(
                                    Icons.schedule,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  '${agenda.horaInicio.substring(0, 5)} - ${agenda.horaFin.substring(0, 5)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Cada ${agenda.intervalo} minutos',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _mostrarDialogoEliminar(agenda.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ] else
            const Expanded(
              child: Center(
                child: Text(
                  'Selecciona un día para ver la agenda',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Agenda'),
        content: const Text('¿Estás segura de eliminar esta configuración?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarAgenda(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Crear Agenda
// ─────────────────────────────────────────
