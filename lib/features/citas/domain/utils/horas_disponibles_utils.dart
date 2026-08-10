/// Reglas puras (sin Flutter) sobre la lista de horas disponibles para
/// reservar una cita.
class HorasDisponiblesUtils {
  HorasDisponiblesUtils._();

  /// Filtra, de una lista de horas "HH:mm", las que ya pasaron cuando
  /// [fecha] (formato yyyy-MM-dd) es el día de hoy. Para cualquier otro
  /// día devuelve la lista sin tocar.
  ///
  /// Sin este filtro, al permitir reservar citas el mismo día, el listado
  /// de horas mostraría slots ya pasados (ej. 08:00 cuando ya son las
  /// 15:00) como si todavía se pudieran agendar.
  static List<String> filtrarPasadas(
    List<String> horas,
    String fecha, {
    DateTime? ahora,
  }) {
    final now = ahora ?? DateTime.now();
    final hoy =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    if (fecha != hoy) return horas;

    final minutosAhora = now.hour * 60 + now.minute;
    return horas.where((hora) {
      final partes = hora.split(':');
      if (partes.length < 2) return true;
      final h = int.tryParse(partes[0]);
      final m = int.tryParse(partes[1]);
      if (h == null || m == null) return true;
      return h * 60 + m > minutosAhora;
    }).toList();
  }
}
