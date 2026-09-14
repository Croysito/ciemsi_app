import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';

/// Tarjeta condicional: aparece sólo cuando el día elegido no tiene
/// horario abierto. Permite crearlo ahí mismo sin salir del flujo de
/// reserva — el hallazgo central de P2.
class TarjetaAbrirHorario extends StatelessWidget {
  final DateTime dia;
  final TimeOfDay desde;
  final TimeOfDay hasta;
  final int intervalo;
  final String rolSeleccionado;
  final bool creando;
  final String? error;
  final ValueChanged<TimeOfDay> onDesdeCambiado;
  final ValueChanged<TimeOfDay> onHastaCambiado;
  final ValueChanged<int> onIntervaloCambiado;
  final ValueChanged<String> onRolCambiado;
  final VoidCallback onCrear;

  const TarjetaAbrirHorario({
    super.key,
    required this.dia,
    required this.desde,
    required this.hasta,
    required this.intervalo,
    required this.rolSeleccionado,
    required this.creando,
    required this.error,
    required this.onDesdeCambiado,
    required this.onHastaCambiado,
    required this.onIntervaloCambiado,
    required this.onRolCambiado,
    required this.onCrear,
  });

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final diaTexto = DateFormat("EEEE d", 'es_ES').format(dia);

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.shadowTarjeta,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_busy, size: 18, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$diaTexto no tiene horario abierto',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Puedes abrirlo aquí mismo: la cita se reserva en el primer cupo que se genere.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4A4F54)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _campoHora('Desde', _fmt(desde), () => _elegirHora(context, desde, onDesdeCambiado))),
                const SizedBox(width: 8),
                Expanded(child: _campoHora('Hasta', _fmt(hasta), () => _elegirHora(context, hasta, onHastaCambiado))),
                const SizedBox(width: 8),
                Expanded(child: _campoIntervalo(context)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _chipRol('Doctora', 'Agenda Doctora')),
                const SizedBox(width: 8),
                Expanded(child: _chipRol('Asistente', 'Asistente')),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: creando ? null : onCrear,
                icon: creando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.event_available, size: 19, color: Colors.white),
                label: Text(
                  creando ? 'Abriendo...' : 'Abrir horario y elegir hora',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _elegirHora(BuildContext context, TimeOfDay actual, ValueChanged<TimeOfDay> onCambiado) async {
    final elegido = await showTimePicker(
      context: context,
      initialTime: actual,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.teal)),
        child: child!,
      ),
    );
    if (elegido != null) onCambiado(elegido);
  }

  Widget _campoHora(String etiqueta, String valor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.borderChip), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etiqueta, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
            Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _campoIntervalo(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final valor = await showModalBottomSheet<int>(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [15, 20, 30, 45, 60]
                  .map((m) => ListTile(title: Text('$m min'), onTap: () => Navigator.pop(ctx, m)))
                  .toList(),
            ),
          ),
        );
        if (valor != null) onIntervaloCambiado(valor);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.borderChip), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cada', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
            Text('$intervalo min', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _chipRol(String valor, String etiqueta) {
    final activo = rolSeleccionado == valor;
    return GestureDetector(
      onTap: () => onRolCambiado(valor),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: activo ? const Color(0x1A00B5C8) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: activo ? AppColors.teal : AppColors.borderChip),
        ),
        child: Text(
          etiqueta,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: activo ? AppColors.tealDark : const Color(0xFF4A4F54)),
        ),
      ),
    );
  }
}
