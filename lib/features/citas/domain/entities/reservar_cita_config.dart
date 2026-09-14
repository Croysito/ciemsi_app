import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';

/// Las diferencias entre las 4 variantes de "Nueva cita" (Doctora,
/// Asistente, Asistente multi-ciudad, Paciente) son pocas y caben en un
/// objeto de configuración — reemplaza a `reservar_cita_doctora_page.dart`,
/// `reservar_cita_asistente_page.dart` y `reservar_cita_paciente_page.dart`,
/// que copiaban casi todo su código entre sí.
class ReservarCitaConfig {
  final bool puedeElegirPaciente;
  final bool puedeCrearPacienteNuevo;
  final bool puedeElegirCiudad;

  /// No se muestra para el rol Paciente: ahí el día sin horario sigue
  /// siendo simplemente no disponible.
  final bool muestraTarjetaAbrirHorario;

  /// Doctora/Asistente registran el adelanto directo en el pie; el
  /// Paciente lo hace en un paso aparte (`PagoAdelantoPage`) tras reservar.
  final bool muestraAdelantoInline;

  final bool esPaciente;
  final int? ciudadFijaId;
  final String? ciudadFijaNombre;

  const ReservarCitaConfig({
    required this.puedeElegirPaciente,
    required this.puedeCrearPacienteNuevo,
    required this.puedeElegirCiudad,
    required this.muestraTarjetaAbrirHorario,
    required this.muestraAdelantoInline,
    required this.esPaciente,
    this.ciudadFijaId,
    this.ciudadFijaNombre,
  });

  factory ReservarCitaConfig.paraUsuario(Usuario usuario) {
    switch (usuario.rol) {
      case 'Doctora':
        return const ReservarCitaConfig(
          puedeElegirPaciente: true,
          puedeCrearPacienteNuevo: true,
          puedeElegirCiudad: true,
          muestraTarjetaAbrirHorario: true,
          muestraAdelantoInline: true,
          esPaciente: false,
        );
      case 'Asistente':
        if (usuario.veTodasCiudades) {
          return const ReservarCitaConfig(
            puedeElegirPaciente: true,
            puedeCrearPacienteNuevo: true,
            puedeElegirCiudad: true,
            muestraTarjetaAbrirHorario: true,
            muestraAdelantoInline: true,
            esPaciente: false,
          );
        }
        return ReservarCitaConfig(
          puedeElegirPaciente: true,
          puedeCrearPacienteNuevo: true,
          puedeElegirCiudad: false,
          muestraTarjetaAbrirHorario: true,
          muestraAdelantoInline: true,
          esPaciente: false,
          ciudadFijaId: usuario.ciudad?.id,
          ciudadFijaNombre: usuario.ciudad?.nombreCiudad,
        );
      default: // Paciente
        return const ReservarCitaConfig(
          puedeElegirPaciente: false,
          puedeCrearPacienteNuevo: false,
          puedeElegirCiudad: false,
          muestraTarjetaAbrirHorario: false,
          muestraAdelantoInline: false,
          esPaciente: true,
        );
    }
  }
}
