import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales del calendario unificado (P3 addendum): el color
/// asignado a cada ciudad nueva (más allá de las tres con color fijo) y qué
/// ciudades están ocultas por el usuario. Vive sólo en el dispositivo — no
/// hay endpoint de "configuración de ciudad" en el backend todavía.
class CalendarioPrefsLocalDataSource {
  static const _keyAsignaciones = 'calendario_ciudad_color_asignaciones';
  static const _keyOcultas = 'calendario_ciudades_ocultas';

  Future<Map<String, int>> obtenerAsignacionesColor() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAsignaciones);
    if (raw == null) return {};
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> guardarAsignacionesColor(Map<String, int> asignaciones) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAsignaciones, jsonEncode(asignaciones));
  }

  Future<Set<String>> obtenerCiudadesOcultas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyOcultas)?.toSet() ?? {};
  }

  Future<void> guardarCiudadesOcultas(Set<String> ciudades) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyOcultas, ciudades.toList());
  }
}
