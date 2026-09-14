import 'package:flutter/material.dart';

enum ModoCalendario { citas, horarios }

/// Conmutador Citas/Horarios — el mes, el día seleccionado y los filtros se
/// conservan al cambiar de modo (el estado vive en `CalendarioPage`, este
/// widget es puramente presentacional).
class ModoSwitch extends StatelessWidget {
  final ModoCalendario modo;
  final ValueChanged<ModoCalendario> onCambiar;

  const ModoSwitch({super.key, required this.modo, required this.onCambiar});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: const Color(0xFFE4E6E8), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(child: _segmento('Citas', ModoCalendario.citas)),
          Expanded(child: _segmento('Horarios', ModoCalendario.horarios)),
        ],
      ),
    );
  }

  Widget _segmento(String texto, ModoCalendario valor) {
    final activo = modo == valor;
    return GestureDetector(
      onTap: () => onCambiar(valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: activo ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: activo ? const [BoxShadow(color: Color(0x1F000000), blurRadius: 2, offset: Offset(0, 1))] : null,
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 13,
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            color: activo ? const Color(0xFF16191C) : const Color(0xFF6B7075),
          ),
        ),
      ),
    );
  }
}
