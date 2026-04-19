abstract class AuthRepository {
  Future<Map<String, dynamic>> iniciarSesion(String email, String password);
  Future<void> recuperarContrasena(String email);
  Future<void> cerrarSesion();
}
