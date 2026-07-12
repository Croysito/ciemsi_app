import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../pages/recuperar_contrasena_page.dart';

/// Formulario de login: email, contraseña, recuperar contraseña y botón de acceso.
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  void _irARecuperarContrasena() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: const RecuperarContrasenaPage(),
        ),
      ),
    );
  }

  void _iniciarSesion() {
    context.read<AuthBloc>().add(
      LoginEvent(
        email: widget.emailController.text.trim(),
        password: widget.passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Color(0xFF00B5C8),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00B5C8), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
            prefixIcon: const Icon(
              Icons.lock_outlined,
              color: Color(0xFF00B5C8),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF00B5C8),
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00B5C8), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _irARecuperarContrasena,
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: Color(0xFF8DC63F)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: state is AuthLoading ? null : _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B5C8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: state is AuthLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
