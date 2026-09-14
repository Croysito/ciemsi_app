import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';

class HorasDisponibles extends StatelessWidget {
  final String titulo;
  final List<String> horas;
  final Set<String> horasOcupadas;
  final String? horaSeleccionada;
  final bool cargando;
  final ValueChanged<String> onSeleccionar;

  const HorasDisponibles({
    super.key,
    required this.titulo,
    required this.horas,
    required this.horasOcupadas,
    required this.horaSeleccionada,
    required this.cargando,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16191C))),
        const SizedBox(height: 8),
        if (cargando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
          )
        else if (horas.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.access_time_outlined, color: AppColors.warning),
                SizedBox(width: 8),
                Expanded(child: Text('No hay horas disponibles para este día', style: TextStyle(color: AppColors.warning))),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: horas.map((hora) {
              final ocupada = horasOcupadas.contains(hora);
              final seleccionada = horaSeleccionada == hora;
              return GestureDetector(
                onTap: ocupada ? null : () => onSeleccionar(hora),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ocupada
                        ? const Color(0xFFF4F5F6)
                        : (seleccionada ? AppColors.teal : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ocupada
                          ? const Color(0xFFE8EAEC)
                          : (seleccionada ? AppColors.teal : AppColors.borderChip),
                    ),
                  ),
                  child: Text(
                    hora,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ocupada ? const Color(0xFFB4B8BC) : (seleccionada ? Colors.white : AppColors.ink),
                      decoration: ocupada ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
