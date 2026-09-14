import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Una columna de ciudad en la matriz comparada: id + nombre (del backend)
/// más abreviatura y color, tomados de la misma configuración fija que usa
/// el calendario unificado (P3) — "no del orden en que llegan los datos".
class CiudadInventario extends Equatable {
  final int id;
  final String nombre;
  final String abrev;
  final Color color;
  final Color colorTexto;

  const CiudadInventario({
    required this.id,
    required this.nombre,
    required this.abrev,
    required this.color,
    required this.colorTexto,
  });

  @override
  List<Object?> get props => [id, nombre, abrev];
}

/// P4 · Tabla `Ciudad | Abrev. | Punto | Texto` del spec — Santa Cruz,
/// Cochabamba y La Paz tienen color fijo; una cuarta ciudad toma el
/// siguiente color de [_paletteExtra] de forma determinística (orden
/// alfabético de las ciudades no fijas), para no variar de una carga a
/// otra sólo porque el backend cambió el orden del listado.
class CiudadInventarioEstilos {
  CiudadInventarioEstilos._();

  static const Map<String, _Fijo> _fijos = {
    'santa cruz': _Fijo('SCZ', Color(0xFF00B5C8), Color(0xFF00838F)),
    'cochabamba': _Fijo('CBA', Color(0xFF8DC63F), Color(0xFF6F9C31)),
    'la paz': _Fijo('LPZ', Color(0xFF9575CD), Color(0xFF6A52A3)),
  };

  static const List<_Fijo> _paletteExtra = [
    _Fijo('---', Color(0xFF5C6BC0), Color(0xFF3949AB)),
    _Fijo('---', Color(0xFFD81B60), Color(0xFFAD1457)),
    _Fijo('---', Color(0xFF8D6E63), Color(0xFF6D4C41)),
  ];

  /// Arma las columnas de ciudad en un orden estable: primero las tres
  /// ciudades conocidas (en el orden fijo de la tabla), luego el resto en
  /// alfabético.
  static List<CiudadInventario> resolver(List<({int id, String nombre})> ciudades) {
    final conocidas = <({int id, String nombre})>[];
    final extra = <({int id, String nombre})>[];
    for (final c in ciudades) {
      if (_fijos.containsKey(c.nombre.trim().toLowerCase())) {
        conocidas.add(c);
      } else {
        extra.add(c);
      }
    }
    conocidas.sort((a, b) => _ordenFijo(a.nombre).compareTo(_ordenFijo(b.nombre)));
    extra.sort((a, b) => a.nombre.compareTo(b.nombre));

    final resultado = <CiudadInventario>[];
    for (final c in conocidas) {
      final fijo = _fijos[c.nombre.trim().toLowerCase()]!;
      resultado.add(CiudadInventario(id: c.id, nombre: c.nombre, abrev: fijo.abrev, color: fijo.color, colorTexto: fijo.colorTexto));
    }
    for (var i = 0; i < extra.length; i++) {
      final c = extra[i];
      final fijo = _paletteExtra[i % _paletteExtra.length];
      resultado.add(CiudadInventario(id: c.id, nombre: c.nombre, abrev: _abreviar(c.nombre), color: fijo.color, colorTexto: fijo.colorTexto));
    }
    return resultado;
  }

  static int _ordenFijo(String nombre) => switch (nombre.trim().toLowerCase()) {
        'santa cruz' => 0,
        'cochabamba' => 1,
        'la paz' => 2,
        _ => 99,
      };

  static String _abreviar(String nombre) {
    final limpio = nombre.trim().toUpperCase();
    if (limpio.length <= 3) return limpio;
    return limpio.substring(0, 3);
  }
}

class _Fijo {
  final String abrev;
  final Color color;
  final Color colorTexto;
  const _Fijo(this.abrev, this.color, this.colorTexto);
}
