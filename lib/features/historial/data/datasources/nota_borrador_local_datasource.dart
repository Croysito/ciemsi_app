import 'package:shared_preferences/shared_preferences.dart';

/// Fuente de datos local para el borrador (texto sin guardar) de una nota
/// de evolución. Es un caché efímero por dispositivo, no forma parte del
/// contrato con el backend (por eso no pasa por [HistorialRepository]).
class NotaBorradorLocalDataSource {
  static String _keyFor(int pacienteId) => 'nota_borrador_$pacienteId';

  Future<String?> obtener(int pacienteId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFor(pacienteId));
  }

  Future<void> guardar(int pacienteId, String texto) async {
    final prefs = await SharedPreferences.getInstance();
    if (texto.trim().isEmpty) {
      await prefs.remove(_keyFor(pacienteId));
    } else {
      await prefs.setString(_keyFor(pacienteId), texto);
    }
  }

  Future<void> eliminar(int pacienteId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(pacienteId));
  }
}
