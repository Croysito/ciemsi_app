import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Snapshot del borrador: qué plantilla estaba activa y el texto de cada
/// una de sus secciones. Vive sólo localmente (SharedPreferences) — nunca
/// viaja al backend tal cual, así que no tiene la restricción de forma que
/// sí tiene `NotaEvolucion.detalle` (un `String` plano).
class NotaBorradorData {
  final String plantillaId;
  final Map<String, String> secciones;

  const NotaBorradorData({required this.plantillaId, required this.secciones});

  bool get estaVacio => secciones.values.every((t) => t.trim().isEmpty);

  bool contenidoIgualA(NotaBorradorData otro) {
    if (plantillaId != otro.plantillaId) return false;
    if (secciones.length != otro.secciones.length) return false;
    for (final entry in secciones.entries) {
      if (otro.secciones[entry.key] != entry.value) return false;
    }
    return true;
  }
}

/// Fuente de datos local para el borrador (sin guardar) de una nota de
/// evolución. Es un caché efímero por dispositivo, no forma parte del
/// contrato con el backend.
class NotaBorradorLocalDataSource {
  static String _keyFor(int pacienteId) => 'nota_borrador_$pacienteId';

  Future<NotaBorradorData?> obtener(int pacienteId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(pacienteId));
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final secciones = Map<String, String>.from(
        (json['secciones'] as Map?) ?? {},
      );
      final data = NotaBorradorData(
        plantillaId: json['plantilla'] as String? ?? 'libre',
        secciones: secciones,
      );
      return data.estaVacio ? null : data;
    } catch (_) {
      // Formato anterior a las plantillas: un `String` plano. Se abre como
      // plantilla Libre con todo el texto en su única sección.
      if (raw.trim().isEmpty) return null;
      return NotaBorradorData(plantillaId: 'libre', secciones: {'libre': raw});
    }
  }

  Future<void> guardar(int pacienteId, NotaBorradorData data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data.estaVacio) {
      await prefs.remove(_keyFor(pacienteId));
    } else {
      await prefs.setString(
        _keyFor(pacienteId),
        jsonEncode({'plantilla': data.plantillaId, 'secciones': data.secciones}),
      );
    }
  }

  Future<void> eliminar(int pacienteId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(pacienteId));
  }
}
