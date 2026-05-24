import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_event.dart';
import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_state.dart';
import 'package:ciemsi_app/features/agenda/presentation/pages/crear_agenda.dart';
import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/features/agenda/data/models/agenda_model.dart';

class AgendaPage extends StatefulWidget {
  final Usuario usuario;

  const AgendaPage({super.key, required this.usuario});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  List<AgendaModel> _agendas = [];
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Set<DateTime> _diasDoctora = {};
  Set<DateTime> _diasAsistente = {};

  @override
  void initState() {
    super.initState();
    context.read<AgendaBloc>().add(CargarAgendasEvent());
  }

  void _recalcularDias(List<AgendaModel> agendas) {
    final diasDoctora = <DateTime>{};
    final diasAsistente = <DateTime>{};
    final ahora = DateTime.now();
    for (int i = -30; i < 365; i++) {
      final dia = ahora.add(Duration(days: i));
      for (final agenda in agendas) {
        if (agenda.estado && _agendaAplicaParaDia(agenda, dia)) {
          final normalDay = DateTime(dia.year, dia.month, dia.day);
          if (agenda.rolCreador == 'Doctora') {
            diasDoctora.add(normalDay);
          } else if (agenda.rolCreador == 'Asistente') {
            diasAsistente.add(normalDay);
          }
        }
      }
    }
    setState(() {
      _agendas = agendas;
      _diasDoctora = diasDoctora;
      _diasAsistente = diasAsistente;
    });
  }

  bool _agendaAplicaParaDia(AgendaModel agenda, DateTime dia) {
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

  void _mostrarOpcionesAgenda(AgendaModel agenda) {
    final rolColor = agenda.rolCreador == 'Doctora'
        ? const Color(0xFF00B5C8)
        : const Color(0xFF8DC63F);
    final rolLabel = agenda.rolCreador ?? 'Sin rol';

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${agenda.horaInicio.substring(0, 5)} — ${agenda.horaFin.substring(0, 5)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                _buildChip(
                  agenda.ciudad.nombreCiudad,
                  Icons.location_on_outlined,
                  Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Cada ${agenda.intervalo} min'
                  '${agenda.diasSemana != null ? ' · ${_formatearDias(agenda.diasSemana!)}' : ''}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                _buildChip(rolLabel, Icons.person_outline, rolColor),
              ],
            ),
            const SizedBox(height: 8),
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
                  color: agenda.estado ? const Color(0xFF8DC63F) : Colors.grey,
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
                  color: agenda.estado ? Colors.orange : const Color(0xFF8DC63F),
                ),
              ),
              title: Text(
                agenda.estado ? 'Desactivar agenda' : 'Activar agenda',
                style: TextStyle(
                  color: agenda.estado ? Colors.orange : const Color(0xFF8DC63F),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<AgendaBloc>()
                    .add(CambiarEstadoAgendaEvent(agenda.id, !agenda.estado));
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
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
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
              context.read<AgendaBloc>().add(EliminarAgendaEvent(id));
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

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayMarker(
    DateTime day, {
    required bool esDoctora,
    required bool esAmbas,
  }) {
    if (esAmbas) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B5C8), Color(0xFF8DC63F)],
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
    final color = esDoctora ? const Color(0xFF00B5C8) : const Color(0xFF8DC63F);
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AgendaBloc, AgendaState>(
      listener: (context, state) {
        if (state is AgendasCargadas) {
          _recalcularDias(state.agendas);
        } else if (state is AgendaOperacionExitosa) {
          final messenger = ScaffoldMessenger.of(context);
          // Determine the last action by checking bloc stream isn't easy;
          // We simply show a generic success and reload.
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Operación realizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<AgendaBloc>().add(CargarAgendasEvent());
        } else if (state is AgendaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
            ),
          );
        }
      },
      child: BlocBuilder<AgendaBloc, AgendaState>(
        builder: (context, state) {
          final cargando = state is AgendaLoading;
          final errorCarga =
              (state is AgendaError && _agendas.isEmpty) ? state.mensaje : null;
          final agendasDia = _agendasDelDia(_selectedDay);

          return Scaffold(
            backgroundColor: const Color(0xFFF4F4F4),
            appBar: AppBar(
              title: const Text(
                'Agenda',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF00B5C8),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      context.read<AgendaBloc>().add(CargarAgendasEvent()),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF8DC63F),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AgendaBloc>(),
                      child: CrearAgendaPage(
                        usuario: widget.usuario,
                        fechaInicial: _selectedDay,
                      ),
                    ),
                  ),
                );
                if (context.mounted) {
                  context.read<AgendaBloc>().add(CargarAgendasEvent());
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Nueva Agenda',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Column(
              children: [
                // Calendario
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TableCalendar(
                    locale: 'es_ES',
                    firstDay: DateTime.now().subtract(const Duration(days: 30)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
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
                        final normalDay =
                            DateTime(day.year, day.month, day.day);
                        final esDoctora = _diasDoctora.contains(normalDay);
                        final esAsistente = _diasAsistente.contains(normalDay);
                        if (!esDoctora && !esAsistente) return null;
                        return _buildDayMarker(
                          day,
                          esDoctora: esDoctora,
                          esAmbas: esDoctora && esAsistente,
                        );
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

                // Leyenda
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendItem(const Color(0xFF00B5C8), 'Doctora'),
                      const SizedBox(width: 16),
                      _legendItem(const Color(0xFF8DC63F), 'Asistente'),
                      const SizedBox(width: 16),
                      _legendItemGradient('Ambas'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

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
                        DateFormat(
                          'EEEE, dd MMMM',
                          'es_ES',
                        ).format(_selectedDay),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B5C8),
                        ),
                      ),
                      const Spacer(),
                      if (agendasDia.isNotEmpty)
                        Text(
                          '${agendasDia.length} configuración${agendasDia.length > 1 ? 'es' : ''}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Lista de agendas del día
                Expanded(
                  child: cargando
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00B5C8),
                          ),
                        )
                      : errorCarga != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      errorCarga,
                                      textAlign: TextAlign.center,
                                      style:
                                          const TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => context
                                          .read<AgendaBloc>()
                                          .add(CargarAgendasEvent()),
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Reintentar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF00B5C8),
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
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    100,
                                  ),
                                  itemCount: agendasDia.length,
                                  itemBuilder: (context, index) {
                                    final agenda = agendasDia[index];
                                    final rolColor =
                                        agenda.rolCreador == 'Doctora'
                                            ? const Color(0xFF00B5C8)
                                            : const Color(0xFF8DC63F);
                                    final rolLabel =
                                        agenda.rolCreador == 'Doctora'
                                            ? 'Dra.'
                                            : 'Asist.';

                                    return Card(
                                      margin:
                                          const EdgeInsets.only(bottom: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Container(
                                              width: 5,
                                              color: rolColor,
                                            ),
                                            Expanded(
                                              child: ListTile(
                                                onTap: () =>
                                                    _mostrarOpcionesAgenda(
                                                  agenda,
                                                ),
                                                leading: CircleAvatar(
                                                  backgroundColor: agenda
                                                          .estado
                                                      ? rolColor
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Cada ${agenda.intervalo} min',
                                                    ),
                                                    if (agenda.diasSemana !=
                                                        null)
                                                      Text(
                                                        _formatearDias(
                                                          agenda.diasSemana!,
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        _buildChip(
                                                          agenda.ciudad
                                                              .nombreCiudad,
                                                          Icons
                                                              .location_on_outlined,
                                                          Colors.grey,
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        _buildChip(
                                                          rolLabel,
                                                          Icons.person_outline,
                                                          rolColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                isThreeLine: true,
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: agenda.estado
                                                            ? const Color(
                                                                0xFF8DC63F,
                                                              ).withValues(
                                                                alpha: 0.15,
                                                              )
                                                            : Colors
                                                                .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        agenda.estado
                                                            ? 'Activa'
                                                            : 'Inactiva',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: agenda.estado
                                                              ? const Color(
                                                                  0xFF8DC63F,
                                                                )
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
        },
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _legendItemGradient(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B5C8), Color(0xFF8DC63F)],
            ),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
