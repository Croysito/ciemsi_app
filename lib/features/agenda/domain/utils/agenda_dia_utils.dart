import 'package:ciemsi_app/features/agenda/domain/entities/agenda.dart';

const List<String> nombresDiaSemana = [
  'DOMINGO',
  'LUNES',
  'MARTES',
  'MIERCOLES',
  'JUEVES',
  'VIERNES',
  'SABADO',
];

/// Regla única de "¿esta franja aplica para este día?" (por `diasSemana`
/// recurrente o por `fecha` puntual) — antes vivía duplicada como método
/// privado en cada pantalla que pintaba un calendario de agenda (reservar
/// cita ×3, `agenda_page.dart`).
class AgendaDiaUtils {
  AgendaDiaUtils._();

  static bool aplicaParaDia(Agenda agenda, DateTime dia) {
    if (agenda.diasSemana != null && agenda.diasSemana!.isNotEmpty) {
      return agenda.diasSemana!.contains(nombresDiaSemana[dia.weekday % 7]);
    }
    if (agenda.fecha != null) {
      return agenda.fecha!.year == dia.year &&
          agenda.fecha!.month == dia.month &&
          agenda.fecha!.day == dia.day;
    }
    return false;
  }

  static Agenda? encontrarParaDiaYRol(
    List<Agenda> agendas,
    DateTime dia,
    String rol,
  ) {
    for (final agenda in agendas) {
      if (agenda.rolCreador == rol && aplicaParaDia(agenda, dia)) {
        return agenda;
      }
    }
    return null;
  }
}
