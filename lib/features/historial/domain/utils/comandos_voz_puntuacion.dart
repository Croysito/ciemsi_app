/// Traduce comandos de puntuación dictados por voz (ej. "punto", "coma",
/// "punto y aparte") a los signos de puntuación correspondientes.
///
/// Es una regla de negocio pura, sin dependencias de Flutter ni de
/// `speech_to_text`, para poder testearla aislada del widget que la usa.
class ComandosVozPuntuacion {
  ComandosVozPuntuacion._();

  // Más largos primero, para no matchear parcialmente dentro de una frase
  // más larga, ej. "punto y aparte" antes que "punto".
  static final List<MapEntry<RegExp, String>> _comandos = [
    MapEntry(
      RegExp(r'\s*\bpunto\s+y\s+aparte\b\s*', caseSensitive: false),
      '\n',
    ),
    MapEntry(
      RegExp(r'\s*\bpunto\s+y\s+seguido\b\s*', caseSensitive: false),
      '. ',
    ),
    MapEntry(RegExp(r'\s*\bnueva\s+l[ií]nea\b\s*', caseSensitive: false), '\n'),
    MapEntry(
      RegExp(r'\s*\bsalto\s+de\s+l[ií]nea\b\s*', caseSensitive: false),
      '\n',
    ),
    MapEntry(RegExp(r'\s*\bdos\s+puntos\b\s*', caseSensitive: false), ': '),
    MapEntry(RegExp(r'\s*\bcoma\b\s*', caseSensitive: false), ', '),
    MapEntry(RegExp(r'\s*\bpunto\b\s*', caseSensitive: false), '. '),
  ];

  /// "siguiente" es un comando de navegación, no de puntuación: cuando el
  /// usuario lo dice solo (aislado por una pausa), salta a la siguiente
  /// sección de la plantilla en vez de insertarse como texto.
  static bool esComandoSiguiente(String texto) =>
      texto.trim().toLowerCase() == 'siguiente';

  static String aplicar(String texto) {
    var resultado = texto;
    for (final comando in _comandos) {
      resultado = resultado.replaceAll(comando.key, comando.value);
    }
    resultado = resultado.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    resultado = resultado.replaceAll(RegExp(r'[ \t]+\n'), '\n');
    resultado = resultado.replaceAll(RegExp(r'\n[ \t]+'), '\n');
    resultado = resultado.replaceAllMapped(
      RegExp(r'\s+([,;:.?)])'),
      (m) => m.group(1)!,
    );
    return resultado.trim();
  }
}
