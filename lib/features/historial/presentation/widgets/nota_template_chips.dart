import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/features/historial/domain/entities/nota_plantilla.dart';

/// Selector de plantilla — fila horizontal desplazable de chips pill.
class NotaTemplateChips extends StatelessWidget {
  final NotaPlantilla seleccionada;
  final ValueChanged<NotaPlantilla> onSeleccionar;

  const NotaTemplateChips({
    super.key,
    required this.seleccionada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        itemCount: NotaPlantilla.todas.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final plantilla = NotaPlantilla.todas[index];
          final activo = plantilla.id == seleccionada.id;
          return GestureDetector(
            onTap: () => onSeleccionar(plantilla),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: activo ? AppColors.teal : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: activo ? AppColors.teal : AppColors.borderChip,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                plantilla.nombre,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: activo ? FontWeight.w500 : FontWeight.normal,
                  color: activo ? Colors.white : const Color(0xFF4A4F54),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
