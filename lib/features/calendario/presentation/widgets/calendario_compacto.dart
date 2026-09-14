import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:ciemsi_app/core/theme/app_colors.dart';
import '../controllers/ciudad_color_controller.dart';
import 'modo_switch.dart';

const List<String> _inicialesDia = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

/// P3 addendum · Calendario compacto, expandable: arranca en una sola fila
/// de semana (~130 px) y sólo crece a mes cuando la doctora lo pide (pie
/// "Ver el mes") o cuando [expandido] llega en `true` desde afuera (la
/// página lo controla según el scroll de la lista del día). El día
/// seleccionado siempre queda dentro de la semana visible.
class CalendarioCompacto extends StatelessWidget {
  final ModoCalendario modo;
  final bool expandido;
  final DateTime focusDay;
  final DateTime diaSeleccionado;

  /// Estilos de ciudad a marcar bajo el número del día — puntos (modo
  /// Citas) o segmentos (modo Horarios); ya viene limitado a 3 en modo
  /// Citas por quien arma la lista.
  final List<CiudadEstilo> Function(DateTime dia) marcasEnDia;

  final ValueChanged<DateTime> onDiaSeleccionado;
  final ValueChanged<DateTime> onFocusDayCambiado;
  final VoidCallback onAlternarExpandido;

  const CalendarioCompacto({
    super.key,
    required this.modo,
    required this.expandido,
    required this.focusDay,
    required this.diaSeleccionado,
    required this.marcasEnDia,
    required this.onDiaSeleccionado,
    required this.onFocusDayCambiado,
    required this.onAlternarExpandido,
  });

  static DateTime _inicioSemana(DateTime dia) =>
      dia.subtract(Duration(days: (dia.weekday - DateTime.monday) % 7));

  void _pagina(int delta) {
    if (expandido) {
      onFocusDayCambiado(DateTime(focusDay.year, focusDay.month + delta, 1));
    } else {
      onFocusDayCambiado(focusDay.add(Duration(days: 7 * delta)));
    }
  }

  String get _titulo {
    if (expandido) {
      final texto = DateFormat('MMMM yyyy', 'es_ES').format(focusDay);
      return texto[0].toUpperCase() + texto.substring(1);
    }
    final inicio = _inicioSemana(focusDay);
    final fin = inicio.add(const Duration(days: 6));
    final mesFin = DateFormat('MMMM', 'es_ES').format(fin);
    if (inicio.month == fin.month) {
      return '${inicio.day} – ${fin.day} $mesFin';
    }
    final mesInicio = DateFormat('MMMM', 'es_ES').format(inicio);
    return '${inicio.day} $mesInicio – ${fin.day} $mesFin';
  }

  void _onPageChanged(DateTime nuevoFoco) {
    onFocusDayCambiado(nuevoFoco);
    onDiaSeleccionado(_mantenerIndice(nuevoFoco));
  }

  /// "Al cambiar de semana o de mes se mantiene el día del mismo índice si
  /// existe": mismo día de la semana en modo semana, mismo número de día
  /// (con clamp) en modo mes.
  DateTime _mantenerIndice(DateTime nuevoFoco) {
    if (!expandido) {
      final inicio = _inicioSemana(nuevoFoco);
      final idx = (diaSeleccionado.weekday - DateTime.monday) % 7;
      return inicio.add(Duration(days: idx));
    }
    final ultimoDia = DateTime(nuevoFoco.year, nuevoFoco.month + 1, 0).day;
    final dia = diaSeleccionado.day.clamp(1, ultimoDia);
    return DateTime(nuevoFoco.year, nuevoFoco.month, dia);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadowTarjeta,
      ),
      child: Column(
        children: [
          _cabecera(),
          const SizedBox(height: 4),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: TableCalendar(
              key: const ValueKey('calendario_compacto'),
              locale: 'es_ES',
              firstDay: DateTime.now().subtract(const Duration(days: 730)),
              lastDay: DateTime.now().add(const Duration(days: 730)),
              focusedDay: focusDay,
              headerVisible: false,
              daysOfWeekVisible: expandido,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarFormat: expandido ? CalendarFormat.month : CalendarFormat.week,
              availableCalendarFormats: const {CalendarFormat.month: 'Mes', CalendarFormat.week: 'Semana'},
              formatAnimationDuration: const Duration(milliseconds: 250),
              rowHeight: expandido ? 44 : 62,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 11, color: AppColors.inkFaint),
                weekendStyle: TextStyle(fontSize: 11, color: AppColors.inkFaint),
              ),
              selectedDayPredicate: (day) => isSameDay(diaSeleccionado, day),
              onDaySelected: (dia, foco) => onDiaSeleccionado(dia),
              onPageChanged: _onPageChanged,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) => _celda(day),
                outsideBuilder: (context, day, focusedDay) => _celda(day, atenuado: true),
                todayBuilder: (context, day, focusedDay) => _celda(day, esHoy: true),
                selectedBuilder: (context, day, focusedDay) => _celda(day, seleccionado: true),
              ),
            ),
          ),
          _piePlegado(),
        ],
      ),
    );
  }

  Widget _cabecera() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left, color: Color(0xFF16191C)),
            onPressed: () => _pagina(-1),
          ),
          Expanded(
            child: Text(
              _titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16191C)),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right, color: Color(0xFF16191C)),
            onPressed: () => _pagina(1),
          ),
        ],
      ),
    );
  }

  Widget _piePlegado() {
    return InkWell(
      onTap: onAlternarExpandido,
      child: Container(
        height: 30,
        margin: const EdgeInsets.only(top: 4),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF0F1F2)))),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(expandido ? Icons.expand_less : Icons.expand_more, size: 18, color: const Color(0xFF757575)),
            const SizedBox(width: 4),
            Text(
              expandido ? 'Ver la semana' : 'Ver el mes',
              style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _celda(DateTime day, {bool esHoy = false, bool seleccionado = false, bool atenuado = false}) {
    final cajaLado = expandido ? 28.0 : 34.0;
    final cajaAlto = expandido ? 22.0 : 34.0;
    final radio = expandido ? 8.0 : 11.0;
    final fuenteNumero = expandido ? 13.0 : 15.0;
    final marcas = marcasEnDia(day);

    return GestureDetector(
      onTap: () => onDiaSeleccionado(day),
      child: Opacity(
        opacity: atenuado ? 0.35 : 1,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!expandido) ...[
                Text(
                  _inicialesDia[day.weekday - 1],
                  style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
                ),
                const SizedBox(height: 2),
              ],
              Container(
                width: cajaLado,
                height: cajaAlto,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: seleccionado ? const Color(0xFF16191C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(radio),
                  border: (esHoy && !seleccionado) ? Border.all(color: AppColors.teal, width: 1.5) : null,
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: fuenteNumero,
                    fontWeight: FontWeight.w700,
                    color: seleccionado ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 4,
                child: modo == ModoCalendario.horarios ? _segmentos(marcas) : _puntos(marcas),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _puntos(List<CiudadEstilo> marcas) {
    if (marcas.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < marcas.length; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Container(width: 6, height: 6, decoration: BoxDecoration(color: marcas[i].color, shape: BoxShape.circle)),
        ],
      ],
    );
  }

  Widget _segmentos(List<CiudadEstilo> marcas) {
    if (marcas.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < marcas.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Container(
            width: 7,
            height: 4,
            decoration: BoxDecoration(color: marcas[i].color, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ],
    );
  }
}
