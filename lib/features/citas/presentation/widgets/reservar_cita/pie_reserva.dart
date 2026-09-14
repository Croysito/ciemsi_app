import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';

/// Pie fijo: siempre visible qué se está por reservar y cuánto se cobra.
/// El botón queda deshabilitado con la razón en el propio texto de la
/// izquierda ("Falta elegir hora") — regla transversal del handoff: nunca
/// una snackbar de validación.
class PieReserva extends StatelessWidget {
  final String resumenFecha;
  final String? montoTexto;
  final bool habilitado;
  final bool reservando;
  final String? razonDeshabilitado;
  final VoidCallback onReservar;

  const PieReserva({
    super.key,
    required this.resumenFecha,
    required this.montoTexto,
    required this.habilitado,
    required this.reservando,
    required this.razonDeshabilitado,
    required this.onReservar,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    habilitado ? resumenFecha : (razonDeshabilitado ?? resumenFecha),
                    style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (montoTexto != null)
                    Text(
                      montoTexto!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF16191C)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (habilitado && !reservando) ? onReservar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  disabledBackgroundColor: const Color(0xFFDCDFE2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  elevation: 0,
                ),
                child: reservando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Reservar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: habilitado ? Colors.white : const Color(0xFF9E9E9E),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
