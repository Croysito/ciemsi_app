import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthStorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _usuarioKey = 'auth_usuario';

  // Guardar token y usuario
  static Future<void> guardarSesion({
    required String token,
    required Map<String, dynamic> usuario,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _usuarioKey, value: jsonEncode(usuario));
  }

  // Obtener token
  static Future<String?> obtenerToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Obtener usuario
  static Future<Map<String, dynamic>?> obtenerUsuario() async {
    final data = await _storage.read(key: _usuarioKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  // Eliminar sesión
  static Future<void> eliminarSesion() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usuarioKey);
  }

  // Verificar si hay sesión activa
  static Future<bool> haySesionActiva() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }
}
