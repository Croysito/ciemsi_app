import 'package:flutter/material.dart';

/// Tokens de diseño de los rediseños P1/P2/P3 (ver
/// `design_handoff_ciemsi_top3/README.md`). Tomados del código actual de la
/// app; se centralizan aquí para no repetirlos como literales en las
/// pantallas nuevas.
///
/// Nota: no reemplaza el resto de la app (54+ archivos siguen con sus
/// literales `Color(0xFF00B5C8)` propios) — eso queda fuera de alcance de
/// este cambio.
class AppColors {
  AppColors._();

  /// Marca — AppBar, acentos, encabezados de sección, rol Doctora.
  static const teal = Color(0xFF00B5C8);

  /// Texto sobre fondos teal claros (contraste AA).
  static const tealDark = Color(0xFF00838F);

  /// Marca — sólo acción primaria.
  static const green = Color(0xFF8DC63F);

  /// Texto verde sobre fondo claro.
  static const greenDark = Color(0xFF6F9C31);

  static const scaffold = Color(0xFFF4F4F4);
  static const surface = Colors.white;

  static const ink = Color(0xDD000000); // rgba(0,0,0,.87)
  static const inkMuted = Color(0xFF757575);
  static const inkFaint = Color(0xFF9E9E9E);

  static const border = Color(0xFFE0E0E0);
  static const borderChip = Color(0xFFDCDFE2);

  static const warning = Color(0xFFFF9800);
  static const danger = Color(0xFFF44336);
  static const payDue = Color(0xFFFF5722);

  static const birthday = Color(0xFFE91E63);
  static const birthdayBg = Color(0xFFFCE4EC);

  // Estados de cita (P3) — el color describe el estado, no la ciudad.
  static const estadoConfirmada = teal;
  static const estadoConfirmadaTexto = tealDark;
  static const estadoPendiente = Color(0xFFFF9800);
  static const estadoPendienteTexto = Color(0xFFE08600);
  static const estadoFaltaPago = Color(0xFFFF5722);
  static const estadoFaltaPagoTexto = Color(0xFFD84315);
  static const estadoCancelada = Color(0xFF9E9E9E);

  // Agenda por rol (franjas de horario en P2/P3).
  static const agendaDoctoraBg = Color(0x2400B5C8); // rgba(0,181,200,.14)
  static const agendaDoctoraBanda = Color(0x1400B5C8); // rgba(0,181,200,.08)
  static const agendaAsistenteBg = Color(0x1F8DC63F); // rgba(141,198,63,.12)
  static const agendaAsistenteBanda = Color(0x148DC63F); // rgba(141,198,63,.08)

  static const shadowTarjeta = [
    BoxShadow(color: Color(0x29000000), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static const shadowFab = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 10, offset: Offset(0, 4)),
  ];
}

/// Escala de espaciado y radios de los rediseños: 4 / 6 / 8 / 10 / 12 / 16 / 20 px.
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const ml = 10.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const xxl = 20.0;

  static const radioChip = 10.0;
  static const radioTarjeta = 14.0;
  static const radioContenedor = 16.0;
  static const radioPill = 20.0;

  /// Mínimo de alto táctil exigido por el handoff para chips y botones.
  static const minTouchTarget = 44.0;
}
