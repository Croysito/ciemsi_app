import 'package:flutter/material.dart';

/// Logo + título + subtítulo animados de la pantalla de login.
class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.scaleAnim,
    required this.fadeAnim,
  });

  final Animation<double> scaleAnim;
  final Animation<double> fadeAnim;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: scaleAnim,
          child: FadeTransition(
            opacity: fadeAnim,
            child: Image.asset(
              'assets/images/logo_ciemsi.png',
              width: 130,
              height: 130,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeTransition(
          opacity: fadeAnim,
          child: const Text(
            'CIEMSI',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00B5C8),
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FadeTransition(
          opacity: fadeAnim,
          child: const Text(
            'Inicia sesión para continuar',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
