import 'package:flutter/foundation.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';

/// Búsqueda, selección y alta rápida de paciente para el flujo de "Nueva
/// cita". Usa mapas crudos (`dynamic`) como ya hacían las pantallas de
/// reserva anteriores — no hay un caso de uso de dominio para "listar
/// pacientes para reservar" todavía, y este flujo no es el lugar para
/// introducirlo.
class PacienteBusquedaController extends ChangeNotifier {
  List<dynamic> pacientes = [];
  dynamic pacienteSeleccionado;
  bool usarPacienteNuevo = false;
  bool cargando = false;
  bool creando = false;

  Future<void> cargar({int? ciudadId}) async {
    cargando = true;
    notifyListeners();
    try {
      final response = await ApiClientProvider.instance.dio.get('/pacientes');
      pacientes = (response.data as List)
          .where((p) => ciudadId == null || p['usuario']?['ciudad']?['id'] == ciudadId)
          .toList();
    } catch (_) {
      // Silencioso: el buscador simplemente queda vacío; el usuario puede
      // reintentar reabriendo la pantalla.
    }
    cargando = false;
    notifyListeners();
  }

  List<dynamic> buscar(String query) {
    if (query.isEmpty) return pacientes;
    final q = query.toLowerCase();
    return pacientes.where((p) {
      final nombre = nombrePaciente(p).toLowerCase();
      final ci = (p['ci'] ?? '').toString().toLowerCase();
      final telefono = (p['telefono'] ?? '').toString().toLowerCase();
      return nombre.contains(q) || ci.contains(q) || telefono.contains(q);
    }).toList();
  }

  void seleccionar(dynamic paciente) {
    pacienteSeleccionado = paciente;
    notifyListeners();
  }

  void limpiarSeleccion() {
    pacienteSeleccionado = null;
    notifyListeners();
  }

  void setUsarPacienteNuevo(bool value) {
    usarPacienteNuevo = value;
    if (value) pacienteSeleccionado = null;
    notifyListeners();
  }

  Future<int?> crearProvisional({
    required String nombre,
    required String telefono,
    required int ciudadId,
  }) async {
    if (nombre.isEmpty || telefono.isEmpty) return null;
    creando = true;
    notifyListeners();
    try {
      final response = await ApiClientProvider.instance.dio.post(
        '/pacientes/provisional',
        data: {
          'nombre': nombre,
          'nombreCompleto': nombre,
          'telefono': telefono,
          'ciudadId': ciudadId,
          'provisional': true,
          'perfilCompleto': false,
        },
      );
      final paciente = _extraerPaciente(response.data);
      final pacienteId = _intValue(paciente?['id']);
      if (paciente == null || pacienteId == null) return null;
      pacienteSeleccionado = paciente;
      pacientes = [paciente, ...pacientes];
      usarPacienteNuevo = false;
      return pacienteId;
    } catch (_) {
      return null;
    } finally {
      creando = false;
      notifyListeners();
    }
  }

  static String nombrePaciente(dynamic paciente) {
    final usuario = paciente?['usuario'];
    if (usuario is Map) {
      return '${usuario['nombre'] ?? ''} ${usuario['apellido'] ?? ''}'.trim();
    }
    return paciente?['nombreCompleto']?.toString() ?? 'Paciente provisional';
  }

  static Map<String, dynamic>? _extraerPaciente(dynamic data) {
    if (data is Map<String, dynamic>) {
      final paciente = data['paciente'];
      if (paciente is Map<String, dynamic>) return paciente;
      return data;
    }
    return null;
  }

  static int? _intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
