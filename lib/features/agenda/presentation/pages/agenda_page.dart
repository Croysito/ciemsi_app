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
  Set<DateTime> _diasConAgenda = {};
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
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
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    try {
      final response = await ApiClientProvider.instance.dio.get(
        '/agenda',
        queryParameters: {'ciudadId': _ciudadSeleccionada!.id},
      );
      debugPrint('[Agenda] Raw response: ${response.data}');

      final lista = response.data;
      if (lista is! List) {
        setState(() {
          _cargando = false;
          _errorCarga = 'Respuesta inesperada del servidor: ${lista.runtimeType}';
        });
        return;
      }

      final agendas = <AgendaModel>[];
      for (final item in lista) {
        try {
          agendas.add(AgendaModel.fromJson(item));
        } catch (e) {
          debugPrint('[Agenda] Error parseando item: $item → $e');
        }
      }

      final diasConAgenda = <DateTime>{};
      final ahora = DateTime.now();
      for (int i = -30; i < 365; i++) {
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
      debugPrint('[Agenda] Error cargando: $e');
      setState(() {
        _cargando = false;
        _errorCarga = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  bool _agendaAplicaParaDia(AgendaModel agenda, DateTime dia) {
    // Verificar primero diasSemana: si tiene días configurados es agenda recurrente
    if (agenda.diasSemana != null && agenda.diasSemana!.isNotEmpty) {
      const dias = [
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
    // Solo si no tiene diasSemana, verificar fecha específica
    if (agenda.fecha != null) {
      return agenda.fecha!.year == dia.year &&
          agenda.fecha!.month == dia.month &&
          agenda.fecha!.day == dia.day;
    }
    return false;
  }

  List<AgendaModel> _agendasDelDia(DateTime dia) {
    return _agendas.where((a) => _agendaAplicaParaDia(a, dia)).toList();
  }

  String _formatearDias(List<String> dias) {
    const nombres = {
      'LUNES': 'Lun',
      'MARTES': 'Mar',
      'MIERCOLES': 'Mié',
      'JUEVES': 'Jue',
      'VIERNES': 'Vie',
      'SABADO': 'Sáb',
      'DOMINGO': 'Dom',
    };
    return dias.map((d) => nombres[d] ?? d).join(' · ');
  }

  Future<void> _cambiarEstadoAgenda(int id, bool nuevoEstado) async {
    try {
      await ApiClientProvider.instance.dio.patch(
        '/agenda/$id',
        data: {'estado': nuevoEstado},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nuevoEstado ? 'Agenda activada' : 'Agenda desactivada'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarAgenda();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarAgenda(int id) async {
    try {
      await ApiClientProvider.instance.dio.delete('/agenda/$id');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda eliminada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarAgenda();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarOpcionesAgenda(AgendaModel agenda) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${agenda.horaInicio.substring(0, 5)} — ${agenda.horaFin.substring(0, 5)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Cada ${agenda.intervalo} min'
              '${agenda.diasSemana != null ? ' · ${_formatearDias(agenda.diasSemana!)}' : ''}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: agenda.estado
                    ? const Color(0xFF8DC63F).withValues(alpha: 0.15)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                agenda.estado ? 'Activa' : 'Inactiva',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: agenda.estado
                      ? const Color(0xFF8DC63F)
                      : Colors.grey,
                ),
              ),
            ),
            const Divider(height: 28),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: (agenda.estado
                        ? Colors.orange
                        : const Color(0xFF8DC63F))
                    .withValues(alpha: 0.15),
                child: Icon(
                  agenda.estado
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  color: agenda.estado
                      ? Colors.orange
                      : const Color(0xFF8DC63F),
                ),
              ),
              title: Text(
                agenda.estado ? 'Desactivar agenda' : 'Activar agenda',
                style: TextStyle(
                  color:
                      agenda.estado ? Colors.orange : const Color(0xFF8DC63F),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _cambiarEstadoAgenda(agenda.id, !agenda.estado);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.red.withValues(alpha: 0.12),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              title: const Text(
                'Eliminar agenda',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoEliminar(agenda.id);
              },
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    final agendasDia = _agendasDelDia(_selectedDay);

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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarAgenda,
          ),
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
                      _focusedDay = DateTime.now();
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
                setState(() => _focusedDay = focusedDay);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final normalDay = DateTime(day.year, day.month, day.day);
                  if (_diasConAgenda.contains(normalDay)) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8DC63F).withValues(alpha: 0.2),
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

          // Encabezado del día seleccionado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF00B5C8),
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('EEEE, dd MMMM', 'es_ES').format(_selectedDay),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B5C8),
                  ),
                ),
                const Spacer(),
                if (agendasDia.isNotEmpty)
                  Text(
                    '${agendasDia.length} configuración${agendasDia.length > 1 ? 'es' : ''}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista de agendas del día
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00B5C8),
                    ),
                  )
                : _errorCarga != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 8),
                              Text(
                                _errorCarga!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _cargarAgenda,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00B5C8),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                : agendasDia.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_busy_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sin agenda para este día',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: agendasDia.length,
                        itemBuilder: (context, index) {
                          final agenda = agendasDia[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () => _mostrarOpcionesAgenda(agenda),
                              leading: CircleAvatar(
                                backgroundColor: agenda.estado
                                    ? const Color(0xFF8DC63F)
                                    : Colors.grey.shade400,
                                child: const Icon(
                                  Icons.schedule,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                '${agenda.horaInicio.substring(0, 5)} — ${agenda.horaFin.substring(0, 5)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cada ${agenda.intervalo} min'),
                                  if (agenda.diasSemana != null)
                                    Text(
                                      _formatearDias(agenda.diasSemana!),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                ],
                              ),
                              isThreeLine: agenda.diasSemana != null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: agenda.estado
                                          ? const Color(
                                              0xFF8DC63F,
                                            ).withValues(alpha: 0.15)
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      agenda.estado ? 'Activa' : 'Inactiva',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: agenda.estado
                                            ? const Color(0xFF8DC63F)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
