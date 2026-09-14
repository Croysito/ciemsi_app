/// Definición de una sección dentro de una plantilla de nota de evolución.
class SeccionDef {
  final String id;

  /// Etiqueta visible (mayúsculas al serializar). Vacía para la plantilla
  /// Libre, que no tiene encabezado.
  final String etiqueta;

  const SeccionDef(this.id, this.etiqueta);
}

/// Plantilla de nota: un conjunto fijo de secciones. Cambiar de plantilla
/// cambia qué campos ve la doctora, pero el texto ya escrito nunca se
/// pierde (ver [NotaPlantilla.migrarSecciones]).
class NotaPlantilla {
  final String id;
  final String nombre;
  final List<SeccionDef> secciones;

  const NotaPlantilla({
    required this.id,
    required this.nombre,
    required this.secciones,
  });

  bool get esLibre => id == 'libre';

  static const evolucion = NotaPlantilla(
    id: 'evolucion',
    nombre: 'Evolución',
    secciones: [
      SeccionDef('motivo', 'Motivo'),
      SeccionDef('evolucion', 'Evolución'),
      SeccionDef('plan', 'Plan'),
    ],
  );

  static const control = NotaPlantilla(
    id: 'control',
    nombre: 'Control',
    secciones: [
      SeccionDef('motivo', 'Motivo'),
      SeccionDef('hallazgos', 'Hallazgos'),
      SeccionDef('indicaciones', 'Indicaciones'),
    ],
  );

  static const procedimiento = NotaPlantilla(
    id: 'procedimiento',
    nombre: 'Procedimiento',
    secciones: [
      SeccionDef('procedimiento', 'Procedimiento'),
      SeccionDef('insumos', 'Insumos usados'),
      SeccionDef('cuidados', 'Cuidados posteriores'),
    ],
  );

  static const libre = NotaPlantilla(
    id: 'libre',
    nombre: 'Libre',
    secciones: [SeccionDef('libre', '')],
  );

  /// Orden en que aparecen los chips selectores. Evolución es el default.
  static const todas = [evolucion, control, procedimiento, libre];

  static NotaPlantilla porId(String id) =>
      todas.firstWhere((p) => p.id == id, orElse: () => evolucion);

  /// Al cambiar de plantilla nunca se pierde contenido: el texto de cada
  /// sección que desaparece se concatena al final de la primera sección de
  /// la plantilla nueva.
  Map<String, String> migrarSecciones(Map<String, String> actuales) {
    final restante = actuales.values
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .join('\n\n');

    final nuevas = <String, String>{for (final s in secciones) s.id: ''};
    if (secciones.isNotEmpty) {
      nuevas[secciones.first.id] = restante;
    }
    return nuevas;
  }

  /// Serializa las secciones a texto plano legible con encabezados — es la
  /// representación canónica que viaja al backend (`NotaEvolucion.detalle`
  /// sigue siendo un `String`; no hace falta cambiar el modelo de datos).
  String serializar(Map<String, String> valores) {
    if (esLibre) {
      return (valores[secciones.first.id] ?? '').trim();
    }
    final buffer = StringBuffer();
    for (final s in secciones) {
      final texto = (valores[s.id] ?? '').trim();
      if (texto.isEmpty) continue;
      if (buffer.isNotEmpty) buffer.write('\n\n');
      buffer.write('${s.etiqueta.toUpperCase()}:\n$texto');
    }
    return buffer.toString().trim();
  }

  bool estaVacia(Map<String, String> valores) =>
      secciones.every((s) => (valores[s.id] ?? '').trim().isEmpty);
}
