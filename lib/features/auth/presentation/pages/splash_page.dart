import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/services/auth_storage_service.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/features/auth/data/models/usuario_model.dart';
import 'package:ciemsi_app/features/auth/presentation/pages/login_page.dart';
import 'package:ciemsi_app/features/auth/presentation/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Precargar imagen antes de animar
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(
        const AssetImage('assets/images/logo_ciemsi.png'),
        context,
      );
      _animController.forward();
      Future.delayed(const Duration(milliseconds: 2000), _verificarSesion);
    });
  }

  Future<void> _verificarSesion() async {
    final haySesion = await AuthStorageService.haySesionActiva();

    if (!mounted) return;

    if (haySesion) {
      // Restaurar token en el cliente
      final token = await AuthStorageService.obtenerToken();
      final usuarioData = await AuthStorageService.obtenerUsuario();

      if (token != null && usuarioData != null) {
        ApiClientProvider.instance.setToken(token);
        final usuario = UsuarioModel.fromJson(usuarioData);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(usuario: usuario)),
        );
      } else {
        _irAlLogin();
      }
    } else {
      _irAlLogin();
    }
  }

  void _irAlLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Image.asset(
                  'assets/images/logo_ciemsi.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeAnim,
              child: const Text(
                'CIEMSI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(height: 48),
            FadeTransition(
              opacity: _fadeAnim,
              child: const CircularProgressIndicator(
                color: Color(0xFF00B5C8),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
