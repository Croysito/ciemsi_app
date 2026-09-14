import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';

/// Etiquetas, colores e íconos legibles para [EstadoCita].
///
/// Antes de esto cada pantalla (citas_page.dart, detalle_cita_page.dart)
/// duplicaba su propio switch privado, y varios lugares mostraban
/// `cita.estado.name` crudo (`PENDIENTE_PAGO`). Regla transversal del
/// handoff: nunca un nombre de enum en pantalla.
extension EstadoCitaX on EstadoCita {
  /// Etiqueta corta en español, para chips y badges.
  String get label {
    switch (this) {
      case EstadoCita.PENDIENTE:
        return 'Pendiente';
      case EstadoCita.PENDIENTE_PAGO:
        return 'Falta pago';
      case EstadoCita.MODIFICADA:
        return 'Modificada';
      case EstadoCita.CONFIRMADA:
        return 'Confirmada';
      case EstadoCita.CANCELADA:
        return 'Cancelada';
      case EstadoCita.COMPLETADA:
        return 'Completada';
    }
  }

  /// Descripción larga, para banners de detalle.
  String get descripcion {
    switch (this) {
      case EstadoCita.PENDIENTE:
        return 'En espera de confirmación';
      case EstadoCita.PENDIENTE_PAGO:
        return 'Esperando comprobante de pago';
      case EstadoCita.MODIFICADA:
        return 'Solicitud de modificación pendiente';
      case EstadoCita.CONFIRMADA:
        return 'Cita médica confirmada';
      case EstadoCita.CANCELADA:
        return 'Esta cita fue cancelada';
      case EstadoCita.COMPLETADA:
        return 'Cita realizada con éxito';
    }
  }

  /// Color principal del estado (barra, ícono).
  Color get color {
    switch (this) {
      case EstadoCita.PENDIENTE:
        return AppColors.estadoPendiente;
      case EstadoCita.PENDIENTE_PAGO:
        return AppColors.estadoFaltaPago;
      case EstadoCita.MODIFICADA:
        return AppColors.estadoPendiente;
      case EstadoCita.CONFIRMADA:
        return AppColors.estadoConfirmada;
      case EstadoCita.CANCELADA:
        return AppColors.estadoCancelada;
      case EstadoCita.COMPLETADA:
        return AppColors.estadoConfirmada;
    }
  }

  /// Color de texto sobre el fondo claro del color principal (contraste AA).
  Color get colorTexto {
    switch (this) {
      case EstadoCita.PENDIENTE:
        return AppColors.estadoPendienteTexto;
      case EstadoCita.PENDIENTE_PAGO:
        return AppColors.estadoFaltaPagoTexto;
      case EstadoCita.MODIFICADA:
        return AppColors.estadoPendienteTexto;
      case EstadoCita.CONFIRMADA:
        return AppColors.estadoConfirmadaTexto;
      case EstadoCita.CANCELADA:
        return AppColors.estadoCancelada;
      case EstadoCita.COMPLETADA:
        return AppColors.estadoConfirmadaTexto;
    }
  }

  IconData get icono {
    switch (this) {
      case EstadoCita.PENDIENTE:
        return Icons.hourglass_empty;
      case EstadoCita.PENDIENTE_PAGO:
        return Icons.payments_outlined;
      case EstadoCita.MODIFICADA:
        return Icons.edit_calendar_outlined;
      case EstadoCita.CONFIRMADA:
        return Icons.check_circle_outline;
      case EstadoCita.CANCELADA:
        return Icons.cancel_outlined;
      case EstadoCita.COMPLETADA:
        return Icons.task_alt_outlined;
    }
  }

  bool get esCancelada => this == EstadoCita.CANCELADA;
}
