import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';

/// Un adjunto elegido durante la redacción, aún no subido (se sube recién
/// después de guardar la nota, cuando ya existe `notaId`).
class AdjuntoPendiente {
  final String nombre;
  final String mimeType;
  final List<int> bytes;

  /// 'IMAGEN' | 'VIDEO' | 'DRIVE' — mismo vocabulario que `TipoLink`.
  final String tipo;

  const AdjuntoPendiente({
    required this.nombre,
    required this.mimeType,
    required this.bytes,
    required this.tipo,
  });
}

class NotaAdjuntoChip extends StatelessWidget {
  final String nombre;
  final VoidCallback? onQuitar;

  const NotaAdjuntoChip({super.key, required this.nombre, this.onQuitar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.agendaAsistenteBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file, size: 16, color: AppColors.green),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.greenDark,
              ),
            ),
          ),
          if (onQuitar != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onQuitar,
              child: const Icon(Icons.close, size: 14, color: AppColors.greenDark),
            ),
          ],
        ],
      ),
    );
  }
}

class NotaAdjuntarChip extends StatelessWidget {
  final VoidCallback onTap;

  const NotaAdjuntarChip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC9CCD0)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Color(0xFF757575)),
            SizedBox(width: 4),
            Text(
              'Adjuntar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }
}
