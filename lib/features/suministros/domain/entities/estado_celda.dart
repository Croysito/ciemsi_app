import 'package:flutter/material.dart';

/// P4 · Inventario comparado — el color de una celda de saldo es la única
/// señal y hay **cuatro** estados, no dos: el cero es un caso propio, nunca
/// una alerta (ver [calcularEstadoCelda]).
enum EstadoCelda { normal, alFilo, bajo, enCero }

/// `saldo == 0` es "en cero" antes que nada — nunca compite con "bajo".
/// Por lo demás, bajo el umbral es prioridad sobre "al filo": si además de
/// estar por debajo también está al 110% o menos, gana "bajo".
EstadoCelda calcularEstadoCelda({required double saldo, required int umbral}) {
  if (saldo <= 0) return EstadoCelda.enCero;
  if (saldo < umbral) return EstadoCelda.bajo;
  if (umbral > 0 && saldo <= umbral * 1.1) return EstadoCelda.alFilo;
  return EstadoCelda.normal;
}

extension EstadoCeldaX on EstadoCelda {
  Color get fondo {
    switch (this) {
      case EstadoCelda.normal:
        return Colors.transparent;
      case EstadoCelda.alFilo:
        return const Color(0x1FFF9800); // rgba(255,152,0,.12)
      case EstadoCelda.bajo:
        return const Color(0x1AF44336); // rgba(244,67,54,.10)
      case EstadoCelda.enCero:
        return const Color(0xFFF2F3F4);
    }
  }

  Color get colorNumero {
    switch (this) {
      case EstadoCelda.normal:
        return const Color(0xFF16191C);
      case EstadoCelda.alFilo:
        return const Color(0xFFE65100);
      case EstadoCelda.bajo:
        return const Color(0xFFC62828);
      case EstadoCelda.enCero:
        return const Color(0xFF9AA0A5);
    }
  }

  /// Etiqueta bajo el número, 9 sp — `null` en Normal (no hace falta
  /// explicar lo que no necesita alerta).
  String? get etiqueta {
    switch (this) {
      case EstadoCelda.normal:
        return null;
      case EstadoCelda.alFilo:
        return 'justo';
      case EstadoCelda.bajo:
        return 'bajo';
      case EstadoCelda.enCero:
        return 'sin uso';
    }
  }

  /// Sólo bajo y al filo cuentan como alerta real — el cero, explícitamente
  /// no ("Regla del cero" del spec).
  bool get esAlerta => this == EstadoCelda.bajo || this == EstadoCelda.alFilo;
}
