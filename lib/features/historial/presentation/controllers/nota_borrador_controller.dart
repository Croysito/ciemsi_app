import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/datasources/nota_borrador_local_datasource.dart';

/// Orquesta el autoguardado, el historial de deshacer y la restauración
/// del borrador local (estructurado por secciones) de una nota de
/// evolución.
///
/// No extiende `State` ni depende del widget tree: solo usa
/// [ChangeNotifier] para avisarle a la UI que debe redibujarse. Así queda
/// testeable aparte de `AgregarNotaPage`.
class NotaBorradorController extends ChangeNotifier {
  NotaBorradorController({
    required this.pacienteId,
    NotaBorradorLocalDataSource? dataSource,
  }) : _dataSource = dataSource ?? NotaBorradorLocalDataSource();

  final int pacienteId;
  final NotaBorradorLocalDataSource _dataSource;

  static const _maxUndo = 20;
  static const _debounce = Duration(milliseconds: 1200);

  final List<NotaBorradorData> _undoStack = [];
  NotaBorradorData _lastCheckpoint = const NotaBorradorData(
    plantillaId: 'libre',
    secciones: {},
  );
  Timer? _debounceTimer;

  bool hayBorradorRestaurado = false;
  bool get puedeDeshacer => _undoStack.isNotEmpty;

  /// Carga el borrador guardado, si existe. Devuelve `null` si no hay
  /// nada (o está vacío) para restaurar.
  Future<NotaBorradorData?> cargar() async {
    final borrador = await _dataSource.obtener(pacienteId);
    if (borrador == null) return null;
    _lastCheckpoint = borrador;
    hayBorradorRestaurado = true;
    notifyListeners();
    return borrador;
  }

  /// Programa el guardado del [data] actual. Con [inmediato] en `true`
  /// (ej. al pausar la app o dejar de dictar) se guarda ya mismo en vez
  /// de esperar el debounce.
  void programarAutoguardado(NotaBorradorData data, {bool inmediato = false}) {
    _debounceTimer?.cancel();
    if (inmediato) {
      _checkpointYGuardar(data);
    } else {
      _debounceTimer = Timer(_debounce, () => _checkpointYGuardar(data));
    }
  }

  void _checkpointYGuardar(NotaBorradorData data) {
    if (!data.contenidoIgualA(_lastCheckpoint)) {
      _undoStack.add(_lastCheckpoint);
      if (_undoStack.length > _maxUndo) _undoStack.removeAt(0);
      _lastCheckpoint = data;
      notifyListeners();
    }
    _dataSource.guardar(pacienteId, data);
  }

  /// Deshace el último checkpoint y devuelve el borrador anterior, o
  /// `null` si no queda nada en la pila de deshacer.
  NotaBorradorData? deshacer() {
    if (_undoStack.isEmpty) return null;
    final anterior = _undoStack.removeLast();
    _lastCheckpoint = anterior;
    _dataSource.guardar(pacienteId, anterior);
    notifyListeners();
    return anterior;
  }

  /// Descarta el borrador restaurado y limpia el historial de deshacer.
  void descartar() {
    _undoStack.clear();
    _lastCheckpoint = const NotaBorradorData(plantillaId: 'libre', secciones: {});
    hayBorradorRestaurado = false;
    _dataSource.eliminar(pacienteId);
    notifyListeners();
  }

  /// La nota ya se guardó "en serio" (contra el backend): el borrador
  /// local queda obsoleto.
  void limpiarTrasGuardar() {
    _dataSource.eliminar(pacienteId);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
