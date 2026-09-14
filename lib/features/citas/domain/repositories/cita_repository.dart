import 'dart:typed_data';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/citas/domain/entities/disponibilidad_dia.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

abstract class CitaRepository {
  Future<List<CitaMedica>> listarCitas();

  /// Una sola cita, para parchar un ítem sin recargar toda la lista.
  Future<CitaMedica> obtenerCita(int id);

  /// Devuelve el citaId de la cita creada
  Future<int> reservarCita({
    required String fecha,
    required String hora,
    required int servicioId,
    int? pacienteId,
    int? ciudadId,
    int? agendaId,
    String? notas,
    double? adelantoMonto,
    String? adelantoMetodo,
  });

  Future<void> modificarCita({
    required int id,
    required String fecha,
    required String hora,
    required int servicioId,
    String? notas,
  });

  Future<void> cambiarEstado(int id, String estado, {String? notas});

  Future<List<Servicio>> listarServicios();

  Future<List<String>> obtenerHorasDisponibles({
    required int ciudadId,
    required String fecha,
  });

  Future<List<DisponibilidadDia>> obtenerDisponibilidadMes({
    required int ciudadId,
    required int anio,
    required int mes,
  });

  Future<Map<String, dynamic>> obtenerQrPago();

  Future<void> actualizarQrPago(String qrLink);

  /// Sube la imagen del QR directo a Drive (sin pasar por copiar/pegar un
  /// link) y actualiza la configuración de la clínica con el resultado.
  Future<String> subirQrPagoImagen({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required String tokens,
  });

  Future<String> subirComprobante({
    required int citaId,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  });

  Future<void> confirmarPago(int citaId);
}
