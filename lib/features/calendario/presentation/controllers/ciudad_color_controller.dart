import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/material.dart' show Color;

import '../../data/datasources/calendario_prefs_local_datasource.dart';

/// Color de una ciudad y su variante de texto (contraste AA sobre el fondo
/// claro del mismo color, para chips, encabezados y barras).
class CiudadEstilo {
  final Color color;
  final Color colorTexto;
  const CiudadEstilo(this.color, this.colorTexto);
}

/// P3 addendum · Color por ciudad: "el color vive en el registro de
/// ciudad, no en el widget. Una ciudad nueva toma el siguiente color de una
/// paleta definida y lo conserva." También guarda qué ciudades están
/// ocultas (reemplaza al filtro de ciudad de la AppBar).
///
/// Las tres ciudades conocidas tienen color fijo de marca. Una ciudad
/// adicional toma el siguiente color libre de [_paletteExtra] la primera
/// vez que aparece y esa asignación se persiste — no vuelve a cambiar
/// aunque cambie el orden en que llegan las ciudades desde el backend.
class CiudadColorController extends ChangeNotifier {
  CiudadColorController({CalendarioPrefsLocalDataSource? dataSource})
      : _dataSource = dataSource ?? CalendarioPrefsLocalDataSource();

  final CalendarioPrefsLocalDataSource _dataSource;

  static const Map<String, CiudadEstilo> _defaults = {
    'santa cruz': CiudadEstilo(Color(0xFF00B5C8), Color(0xFF00838F)),
    'cochabamba': CiudadEstilo(Color(0xFF8DC63F), Color(0xFF6F9C31)),
    'la paz': CiudadEstilo(Color(0xFF7B5EA7), Color(0xFF6A4F92)),
  };

  static const List<CiudadEstilo> _paletteExtra = [
    CiudadEstilo(Color(0xFF5C6BC0), Color(0xFF3949AB)), // índigo
    CiudadEstilo(Color(0xFFD81B60), Color(0xFFAD1457)), // magenta
    CiudadEstilo(Color(0xFF8D6E63), Color(0xFF6D4C41)), // tierra
    CiudadEstilo(Color(0xFF26A69A), Color(0xFF00796B)), // petróleo
  ];

  static const puntoInactivo = Color(0xFFC9CCD0);
  static const textoInactivo = Color(0xFF9AA0A5);
  static const bordeInactivo = Color(0xFFE2E4E6);

  Map<String, int> _asignaciones = {};
  Set<String> _ciudadesOcultas = {};
  bool cargado = false;

  Set<String> get ciudadesOcultas => _ciudadesOcultas;

  String _clave(String ciudad) => ciudad.trim().toLowerCase();

  Future<void> cargar() async {
    _asignaciones = await _dataSource.obtenerAsignacionesColor();
    _ciudadesOcultas = await _dataSource.obtenerCiudadesOcultas();
    cargado = true;
    notifyListeners();
  }

  /// Estilo de [ciudad]. Si es la primera vez que se ve una ciudad fuera de
  /// las tres por defecto, le asigna y persiste el siguiente color libre.
  CiudadEstilo estiloPara(String ciudad) {
    final clave = _clave(ciudad);
    final fijo = _defaults[clave];
    if (fijo != null) return fijo;

    final existente = _asignaciones[clave];
    final int indice;
    if (existente != null) {
      indice = existente;
    } else {
      final usados = _asignaciones.values.toSet();
      var libre = 0;
      while (usados.contains(libre) && libre < 1000) {
        libre = libre + 1;
      }
      indice = libre;
      _asignaciones = {..._asignaciones, clave: indice};
      _dataSource.guardarAsignacionesColor(_asignaciones);
    }
    return _paletteExtra[indice % _paletteExtra.length];
  }

  bool estaOculta(String ciudad) => _ciudadesOcultas.contains(_clave(ciudad));

  void alternarVisibilidad(String ciudad) {
    final clave = _clave(ciudad);
    final nuevas = {..._ciudadesOcultas};
    if (!nuevas.remove(clave)) nuevas.add(clave);
    _ciudadesOcultas = nuevas;
    notifyListeners();
    _dataSource.guardarCiudadesOcultas(nuevas);
  }
}
