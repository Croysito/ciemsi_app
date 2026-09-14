import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';

/// Fila de dictado: botón de micrófono, visualizador de nivel de audio y
/// botón de teclado.
class DictadoBar extends StatelessWidget {
  final bool isRecording;

  /// 0.0 (silencio) .. 1.0 (fuerte), ya normalizado.
  final double audioLevel;

  final String? seccionActivaLabel;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleKeyboard;
  final bool micDisponible;

  const DictadoBar({
    super.key,
    required this.isRecording,
    required this.audioLevel,
    required this.seccionActivaLabel,
    required this.onToggleMic,
    required this.onToggleKeyboard,
    this.micDisponible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: micDisponible ? onToggleMic : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: !micDisponible
                  ? const Color(0xFFC9CCD0)
                  : (isRecording ? AppColors.danger : AppColors.teal),
              boxShadow: isRecording
                  ? [
                      BoxShadow(
                        color: AppColors.danger.withValues(alpha: 0.15),
                        blurRadius: 0,
                        spreadRadius: 6,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Visualizador(isRecording: isRecording, audioLevel: audioLevel),
              const SizedBox(height: 4),
              _Leyenda(isRecording: isRecording, seccionActivaLabel: seccionActivaLabel),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onToggleKeyboard,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderChip),
            ),
            child: const Icon(Icons.keyboard, size: 22, color: Color(0xFF4A4F54)),
          ),
        ),
      ],
    );
  }
}

/// Zona 4 del layout: la fila de dictado + el botón primario, fijos al pie
/// de la pantalla, con el mismo fondo/borde superior. No se desplaza y no
/// la tapa el teclado del sistema (se usa como `bottomNavigationBar`, que
/// Scaffold ya mantiene por encima del inset del teclado).
class NotaBarraTrabajo extends StatelessWidget {
  final bool isRecording;
  final double audioLevel;
  final String? seccionActivaLabel;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleKeyboard;
  final bool micDisponible;

  final bool guardarHabilitado;
  final bool guardando;
  final String? razonDeshabilitado;
  final VoidCallback onGuardar;

  const NotaBarraTrabajo({
    super.key,
    required this.isRecording,
    required this.audioLevel,
    required this.seccionActivaLabel,
    required this.onToggleMic,
    required this.onToggleKeyboard,
    required this.guardarHabilitado,
    required this.guardando,
    required this.razonDeshabilitado,
    required this.onGuardar,
    this.micDisponible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Color(0xFFE6E8EA))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DictadoBar(
              isRecording: isRecording,
              audioLevel: audioLevel,
              seccionActivaLabel: seccionActivaLabel,
              onToggleMic: onToggleMic,
              onToggleKeyboard: onToggleKeyboard,
              micDisponible: micDisponible,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (guardarHabilitado && !guardando) ? onGuardar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: guardarHabilitado ? AppColors.green : const Color(0xFFDCDFE2),
                  disabledBackgroundColor: const Color(0xFFDCDFE2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 20, color: guardarHabilitado ? Colors.white : const Color(0xFF9E9E9E)),
                          const SizedBox(width: 8),
                          Text(
                            'Guardar en historial',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: guardarHabilitado ? Colors.white : const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (!guardarHabilitado && razonDeshabilitado != null) ...[
              const SizedBox(height: 6),
              Text(
                razonDeshabilitado!,
                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Visualizador extends StatelessWidget {
  final bool isRecording;
  final double audioLevel;

  const _Visualizador({required this.isRecording, required this.audioLevel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Row(
        children: List.generate(10, (i) {
          double alto = 6;
          if (isRecording) {
            // Variación por barra para que no se muevan en bloque: cada una
            // reacciona un poco distinto al mismo nivel de audio.
            final variacion = 0.55 + 0.45 * sin(i * 1.7);
            alto = 6 + (16 * audioLevel * variacion).clamp(0, 16);
          }
          return Padding(
            padding: const EdgeInsets.only(right: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 3,
              height: alto.toDouble(),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  final bool isRecording;
  final String? seccionActivaLabel;

  const _Leyenda({required this.isRecording, required this.seccionActivaLabel});

  @override
  Widget build(BuildContext context) {
    if (!isRecording) {
      return const Text(
        'Toca el micrófono para dictar',
        style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
      );
    }
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
        children: [
          const TextSpan(text: 'Dictando en '),
          TextSpan(
            text: seccionActivaLabel ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF16191C)),
          ),
          const TextSpan(text: " · di 'punto' o 'nuevo párrafo'"),
        ],
      ),
    );
  }
}
