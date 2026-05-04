import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_event.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_state.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'reservar_cita_page.dart';
import 'detalle_cita_page.dart';

class CitasPage extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback? onMenuTap;
  const CitasPage({super.key, required this.usuario, this.onMenuTap});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Colores por ciudad
  final Map<String, Color> _coloresCiudad = {};
  final List<Color> _paleta = [
    const Color(0xFF00B5C8),
    const Color(0xFF8DC63F),
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
  ];

  Color _getColorCiudad(String ciudad) {
    if (!_coloresCiudad.containsKey(ciudad)) {
      _coloresCiudad[ciudad] = _paleta[_coloresCiudad.length % _paleta.length];
    }
    return _coloresCiudad[ciudad]!;
  }

  Color _colorEstado(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.PENDIENTE:
        return Colors.orange;
      case EstadoCita.MODIFICADA:
        return Colors.purple;
      case EstadoCita.CONFIRMADA:
        return const Color(0xFF00B5C8);
      case EstadoCita.CANCELADA:
        return Colors.red;
      case EstadoCita.COMPLETADA:
        return const Color(0xFF8DC63F);
    }
  }

  IconData _iconoEstado(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.PENDIENTE:
        return Icons.schedule;
      case EstadoCita.MODIFICADA:
        return Icons.edit_calendar;
      case EstadoCita.CONFIRMADA:
        return Icons.check_circle_outline;
      case EstadoCita.CANCELADA:
        return Icons.cancel_outlined;
      case EstadoCita.COMPLETADA:
        return Icons.task_alt;
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<CitaBloc>().add(ListarCitasEvent());
  }

  List<CitaMedica> _citasDelDia(List<CitaMedica> citas, DateTime dia) {
    return citas.where((c) {
      return c.fecha.year == dia.year &&
          c.fecha.month == dia.month &&
          c.fecha.day == dia.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        leading: widget.onMenuTap != null
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: widget.onMenuTap,
              )
            : null,
        title: const Text(
          'Citas Médicas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CitaBloc>().add(ListarCitasEvent()),
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
                value: context.read<CitaBloc>(),
                child: ReservarCitaPage(usuario: widget.usuario),
              ),
            ),
          );
          context.read<CitaBloc>().add(ListarCitasEvent());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva Cita', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<CitaBloc, CitaState>(
        builder: (context, state) {
          if (state is CitaLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }

          if (state is CitaError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    state.mensaje,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CitaBloc>().add(ListarCitasEvent()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is CitaReservada ||
              state is EstadoCitaCambiado ||
              state is CitaModificada) {
            context.read<CitaBloc>().add(ListarCitasEvent());
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }

          if (state is CitasListadas) {
            final citas = state.citas;
            final citasDelDia = _citasDelDia(citas, _selectedDay);

            return Column(
              children: [
                // Leyenda de ciudades
                if (_coloresCiudad.isNotEmpty) _buildLeyendaCiudades(),

                // Calendario
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TableCalendar(
                    locale: 'es_ES',
                    firstDay: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
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
                        final citasDia = _citasDelDia(citas, day);
                        if (citasDia.isEmpty) return null;

                        // Mostrar puntos de colores por ciudad
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: citasDia
                                  .take(3)
                                  .map(
                                    (c) => Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(right: 2),
                                      decoration: BoxDecoration(
                                        color: _getColorCiudad(
                                          c.ciudad.nombreCiudad,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
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

                // Título del día
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        _nombreDia(_selectedDay),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B5C8),
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B5C8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${citasDelDia.length} cita${citasDelDia.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Color(0xFF00B5C8),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de citas del día
                Expanded(
                  child: citasDelDia.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay citas para este día',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: citasDelDia.length,
                          itemBuilder: (context, index) {
                            final cita = citasDelDia[index];
                            return _buildCitaCard(context, cita);
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLeyendaCiudades() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(
        spacing: 12,
        children: _coloresCiudad.entries
            .map(
              (e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: e.value,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    e.key,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCitaCard(BuildContext context, CitaMedica cita) {
    final colorCiudad = _getColorCiudad(cita.ciudad.nombreCiudad);
    final colorEstado = _colorEstado(cita.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CitaBloc>(),
                child: DetalleCitaPage(cita: cita),
              ),
            ),
          );
          context.read<CitaBloc>().add(ListarCitasEvent());
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: colorCiudad, width: 5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Hora
                Column(
                  children: [
                    Text(
                      cita.hora.substring(0, 5),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorCiudad,
                      ),
                    ),
                    Text(
                      cita.ciudad.nombreCiudad,
                      style: TextStyle(fontSize: 10, color: colorCiudad),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const VerticalDivider(width: 1),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cita.paciente.nombreCompleto,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cita.servicio.nombreServicio,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorEstado.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _iconoEstado(cita.estado),
                        color: colorEstado,
                        size: 16,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cita.estado.name,
                        style: TextStyle(
                          color: colorEstado,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _nombreDia(DateTime fecha) {
    const dias = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${dias[fecha.weekday % 7]} ${fecha.day} de ${meses[fecha.month - 1]}';
  }
}
