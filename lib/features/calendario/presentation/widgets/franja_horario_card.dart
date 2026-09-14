import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/features/agenda/domain/entities/agenda.dart';

/// P3 addendum · Franja de horario simplificada: la banda de modo Citas
/// sólo lleva hora y rol (intervalo y cupos se ven al tocarla); la tarjeta
/// de modo Horarios cambia su barra a color de ciudad y ya no tiene chip de
/// Activa/Inactiva — una franja pausada baja su opacidad y lo dice en
/// texto.
class FranjaHorarioCard extends StatelessWidget {
  final Agenda agenda;
  final int cuposLibres;
  final bool compacto;
  final Color color;
  final Color colorTexto;
  final VoidCallback? onTap;

  const FranjaHorarioCard({
    super.key,
    required this.agenda,
    required this.cuposLibres,
    required this.compacto,
    required this.color,
    required this.colorTexto,
    this.onTap,
  });

  bool get _esDoctora => agenda.rolCreador == 'Doctora';

  @override
  Widget build(BuildContext context) {
    return compacto ? _bandaCompacta() : _tarjetaCompleta();
  }

  Widget _bandaCompacta() {
    final rolCorto = _esDoctora ? 'Dra.' : 'Asist.';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: CustomPaint(
          foregroundPainter: _DashedRRectPainter(color: color.withValues(alpha: 0.45), radius: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 16, color: colorTexto),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_hora(agenda.horaInicio)} – ${_hora(agenda.horaFin)}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorTexto),
                  ),
                ),
                Text(rolCorto, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorTexto)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaCompleta() {
    final pausada = !agenda.estado;
    final subtitulo =
        '${agenda.ciudad.nombreCiudad} · cada ${agenda.intervalo} min · $cuposLibres cupos libres${pausada ? ' · Pausada' : ''}';

    return Opacity(
      opacity: pausada ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.shadowTarjeta,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_hora(agenda.horaInicio)} — ${_hora(agenda.horaFin)} · ${_esDoctora ? 'Dra.' : 'Asist.'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF16191C)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitulo,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _hora(String h) => h.length >= 5 ? h.substring(0, 5) : h;
}

/// Borde punteado de radio redondeado — Flutter no trae `BorderStyle.dashed`
/// para `Border`, así que se pinta a mano sobre el `RRect` del contenedor.
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  const _DashedRRectPainter({
    required this.color,
    this.radius = 12,
  })  : dashWidth = 4,
        dashGap = 3,
        strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final siguiente = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, siguiente), paint);
        distance = siguiente + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
