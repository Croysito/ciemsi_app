import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/citas/domain/entities/estado_cita_extension.dart';

/// P3 addendum · Tarjeta de cita dentro de un grupo de ciudad: la barra
/// izquierda ahora lleva el **color de la ciudad** (ya no el del estado —
/// ese vive sólo en el chip de la derecha) y la hora pasa a tinta neutra.
/// Como la ciudad ya está en el encabezado del grupo, la segunda línea
/// muestra sólo el servicio.
class CitaCard extends StatelessWidget {
  final CitaMedica cita;
  final Color colorCiudad;
  final VoidCallback onTap;

  const CitaCard({super.key, required this.cita, required this.colorCiudad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cancelada = cita.estado.esCancelada;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.shadowTarjeta,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: colorCiudad, width: 4)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 46,
                  child: Text(
                    cita.hora.length >= 5 ? cita.hora.substring(0, 5) : cita.hora,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF16191C)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cita.paciente.nombreCompleto,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: cancelada ? TextDecoration.lineThrough : null,
                          color: cancelada ? AppColors.inkFaint : AppColors.ink,
                        ),
                      ),
                      Text(
                        cita.servicio.nombreServicio,
                        style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cita.estado.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    cita.estado.label,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cita.estado.colorTexto),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
