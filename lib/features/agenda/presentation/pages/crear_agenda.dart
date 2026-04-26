import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';

import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';

class CrearAgendaPage extends StatefulWidget {
  final List<Ciudad> ciudades;
  final Ciudad? ciudadInicial;
  final DateTime? fechaInicial;

  const CrearAgendaPage({
    super.key,
    required this.ciudades,
    this.ciudadInicial,
    this.fechaInicial,
  });

  @override
  State<CrearAgendaPage> createState() => _CrearAgendaPageState();
}

class _CrearAgendaPageState extends State<CrearAgendaPage> {
  Ciudad? _ciudadSeleccionada;
  DateTime? _fechaSeleccionada;
  DateTime _focusedDay = DateTime.now();
  final List<String> _diasSeleccionados = [];
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  int _intervalo = 30;
  bool _esFechaEspecifica = true;
  bool _guardando = false;

  final List<String> _diasSemana = [
    'LUNES',
    'MARTES',
    'MIERCOLES',
    'JUEVES',
    'VIERNES',
    'SABADO',
    'DOMINGO',
  ];

  @override
  void initState() {
    super.initState();
    _ciudadSeleccionada = widget.ciudadInicial;
    _fechaSeleccionada = widget.fechaInicial;
    if (widget.fechaInicial != null) {
      _focusedDay = widget.fechaInicial!;
    }
  }

  String _formatHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _seleccionarHora(bool esInicio) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: esInicio
          ? const TimeOfDay(hour: 8, minute: 0)
          : const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF00B5C8)),
        ),
        child: child!,
      ),
    );
    if (hora != null) {
      setState(() {
        if (esInicio) {
          _horaInicio = hora;
        } else {
          _horaFin = hora;
        }
      });
    }
  }

  Future<void> _guardar() async {
    if (_ciudadSeleccionada == null ||
        _horaInicio == null ||
        _horaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ciudad, hora inicio y hora fin son requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_esFechaEspecifica && _fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una fecha en el calendario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_esFechaEspecifica && _diasSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un día'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await ApiClientProvider.instance.dio.post(
        '/agenda',
        data: {
          if (_esFechaEspecifica && _fechaSeleccionada != null)
            'fecha': DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!),
          if (!_esFechaEspecifica) 'diasSemana': _diasSeleccionados,
          'horaInicio': _formatHora(_horaInicio!),
          'horaFin': _formatHora(_horaFin!),
          'intervalo': _intervalo,
          'ciudadId': _ciudadSeleccionada!.id,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda creada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Nueva Agenda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ciudad
            const Text(
              'Ciudad',
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
                child: DropdownButton<Ciudad>(
                  isExpanded: true,
                  value: _ciudadSeleccionada,
                  items: widget.ciudades
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.nombreCiudad),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _ciudadSeleccionada = value),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tipo
            const Text(
              'Tipo de agenda',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B5C8),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _esFechaEspecifica = true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _esFechaEspecifica
                            ? const Color(0xFF00B5C8)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00B5C8)),
                      ),
                      child: Text(
                        'Fecha específica',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _esFechaEspecifica
                              ? Colors.white
                              : const Color(0xFF00B5C8),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _esFechaEspecifica = false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: !_esFechaEspecifica
                            ? const Color(0xFF00B5C8)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00B5C8)),
                      ),
                      child: Text(
                        'Días de semana',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_esFechaEspecifica
                              ? Colors.white
                              : const Color(0xFF00B5C8),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calendario o días
            if (_esFechaEspecifica) ...[
              const Text(
                'Selecciona la fecha',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(_fechaSeleccionada, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _fechaSeleccionada = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF00B5C8),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFF8DC63F),
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
            ] else ...[
              const Text(
                'Días de la semana',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _diasSemana.map((dia) {
                  final seleccionado = _diasSeleccionados.contains(dia);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (seleccionado) {
                          _diasSeleccionados.remove(dia);
                        } else {
                          _diasSeleccionados.add(dia);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? const Color(0xFF00B5C8)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF00B5C8)),
                      ),
                      child: Text(
                        dia.substring(0, 3),
                        style: TextStyle(
                          color: seleccionado
                              ? Colors.white
                              : const Color(0xFF00B5C8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),

            // Horarios
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hora inicio',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B5C8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _seleccionarHora(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF00B5C8),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _horaInicio != null
                                    ? _formatHora(_horaInicio!)
                                    : 'Inicio',
                                style: TextStyle(
                                  color: _horaInicio != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hora fin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B5C8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _seleccionarHora(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF00B5C8),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _horaFin != null
                                    ? _formatHora(_horaFin!)
                                    : 'Fin',
                                style: TextStyle(
                                  color: _horaFin != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Intervalo
            const Text(
              'Intervalo entre citas',
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
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _intervalo,
                  items: [15, 20, 30, 45, 60]
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text('$m minutos'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _intervalo = value!),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8DC63F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar Agenda',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
