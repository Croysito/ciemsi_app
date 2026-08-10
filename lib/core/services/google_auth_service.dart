import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '369719553016-v37hjsk0jlv1j971bbupr2dmv095i58h.apps.googleusercontent.com',
    scopes: ['email', 'https://www.googleapis.com/auth/drive.file'],
  );

  static Future<String?> obtenerTokens() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;

      final tokens = {
        'access_token': auth.accessToken,
        'id_token': auth.idToken,
      };

      return jsonEncode(tokens);
    } catch (e) {
      throw Exception('Error al autenticar con Google: $e');
    }
  }

  static Future<void> cerrarSesion() async {
    await _googleSignIn.signOut();
  }
}
