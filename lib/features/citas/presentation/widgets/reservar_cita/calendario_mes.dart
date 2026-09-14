import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/features/citas/domain/entities/disponibilidad_dia.dart';

/// Calendario de "Nueva cita": a diferencia de la pantalla anterior, un día
/// sin horario abierto se pinta distinto pero sigue siendo tocable — es la
/// puerta de entrada a la tarjeta de "abrir horario aquí mismo".
class CalendarioMes extends StatelessWidget {
  final DateTime mesVisible;
  final DateTime? fechaSeleccionada;
  final Map<String, DisponibilidadDia> disponibilidad;
  final bool cargando;
  final ValueChanged<DateTime> onDiaSeleccionado;
  final ValueChanged<DateTime> onMesCambiado;

  const CalendarioMes({
    super.key,
    required this.mesVisible,
    required this.fechaSeleccionada,
    required this.disponibilidad,
    required this.cargando,
    required this.onDiaSeleccionado,
    required this.onMesCambiado,
  });

  static DateTime get _hoy {
    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, ahora.day);
  }

  String _key(DateTime dia) => DateFormat('yyyy-MM-dd').format(dia);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.shadowTarjeta,
          ),
          child: TableCalendar(
            locale: 'es_ES',
            firstDay: _hoy.subtract(const Duration(days: 365)),
            lastDay: _hoy.add(const Duration(days: 365)),
            focusedDay: mesVisible,
            selectedDayPredicate: (day) => isSameDay(fechaSeleccionada, day),
            enabledDayPredicate: (day) => !day.isBefore(_hoy),
            onDaySelected: (selectedDay, focusedDay) => onDiaSeleccionado(selectedDay),
            onPageChanged: onMesCambiado,
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 11, color: AppColors.inkFaint),
              weekendStyle: TextStyle(fontSize: 11, color: AppColors.inkFaint),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF16191C)),
              leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF16191C)),
              rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF16191C)),
            ),
            calendarStyle: const CalendarStyle(outsideDaysVisible: false),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) => _celda(day),
              todayBuilder: (context, day, focusedDay) => _celda(day, esHoy: true),
              disabledBuilder: (context, day, focusedDay) => _celda(day, pasado: true),
              selectedBuilder: (context, day, focusedDay) => _celda(day, seleccionado: true),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _leyendaItem(const Color(0xFF00B5C8), 'Con cupos'),
            const SizedBox(width: 14),
            _leyendaItem(const Color(0xFFF1F2F3), 'Sin horario'),
          ],
        ),
      ],
    );
  }

  Widget _celda(DateTime day, {bool esHoy = false, bool pasado = false, bool seleccionado = false}) {
    if (pasado) {
      return Center(
        child: Text('${day.day}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFD5D7D9))),
      );
    }

    Color bg;
    Color texto;
    if (seleccionado) {
      bg = AppColors.teal;
      texto = Colors.white;
    } else if (cargando) {
      bg = const Color(0xFFF1F2F3);
      texto = const Color(0xFF9AA0A5);
    } else {
      final dispo = disponibilidad[_key(day)];
      final tieneCupos = dispo != null && dispo.tieneHorario && dispo.cuposLibres > 0;
      if (tieneCupos) {
        bg = const Color(0x2400B5C8);
        texto = AppColors.tealDark;
      } else {
        bg = const Color(0xFFF1F2F3);
        texto = const Color(0xFF9AA0A5);
      }
    }

    return GestureDetector(
      onTap: () => onDiaSeleccionado(day),
      child: Container(
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9),
          border: esHoy && !seleccionado ? Border.all(color: AppColors.teal, width: 1.5) : null,
        ),
        child: Text('${day.day}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: texto)),
      ),
    );
  }

  Widget _leyendaItem(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
      ],
    );
  }
}
