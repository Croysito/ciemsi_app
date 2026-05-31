import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../bloc/cita_bloc.dart';
import '../bloc/cita_event.dart';
import '../bloc/cita_state.dart';

class PagoAdelantoPage extends StatefulWidget {
  final int citaId;
  final SharedMediaFile? archivoInicial;

  const PagoAdelantoPage({
    super.key,
    required this.citaId,
    this.archivoInicial,
  });

  @override
  State<PagoAdelantoPage> createState() => _PagoAdelantoPageState();
}

class _PagoAdelantoPageState extends State<PagoAdelantoPage> {
  String? _archivoNombre;
  Uint8List? _archivoBytes;
  String? _archivoMime;
  bool _subiendoQr = false;
  String? _qrLink;
  double _adelantoMonto = 50;

  String? _normalizarLinkImagen(String? link) {
    if (link == null || link.trim().isEmpty) return null;
    final limpio = link.trim();
    final driveId = RegExp(
      r'drive\.google\.com\/(?:file\/d\/|open\?id=)([^\/&?]+)',
    ).firstMatch(limpio)?.group(1);
    if (driveId != null && driveId.isNotEmpty) {
      return 'https://drive.google.com/uc?export=view&id=$driveId';
    }
    return limpio;
  }

  @override
  void initState() {
    super.initState();
    context.read<CitaBloc>().add(ObtenerQrPagoEvent());
    if (widget.archivoInicial != null) {
      _cargarArchivoInicial(widget.archivoInicial!);
    }
  }

  Future<void> _cargarArchivoInicial(SharedMediaFile archivo) async {
    try {
      final bytes = await File(archivo.path).readAsBytes();
      final nombre = archivo.path.split('/').last;
      final ext = nombre.split('.').last.toLowerCase();
      final mime = ext == 'pdf' ? 'application/pdf' : 'image/$ext';
      if (mounted) {
        setState(() {
          _archivoBytes = bytes;
          _archivoNombre = nombre;
          _archivoMime = mime;
        });
      }
    } catch (_) {
      // Si no se puede leer, el usuario selecciona manualmente
    }
  }

  Future<void> _seleccionarComprobante() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    setState(() {
      _archivoNombre = file.name;
      _archivoBytes = file.bytes;
      _archivoMime = file.extension == 'pdf'
          ? 'application/pdf'
          : 'image/${file.extension}';
    });
  }

  void _subirComprobante() {
    if (_archivoBytes == null) return;
    context.read<CitaBloc>().add(
      SubirComprobanteEvent(
        citaId: widget.citaId,
        bytes: _archivoBytes!.toList(),
        fileName: _archivoNombre!,
        mimeType: _archivoMime!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Confirmar Reserva',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<CitaBloc, CitaState>(
        listener: (context, state) {
          if (state is QrPagoCargado) {
            setState(() {
              _qrLink = state.qrLink;
              _adelantoMonto = state.adelantoMonto;
            });
          }
          if (state is ComprobanteSubido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Comprobante enviado. La doctora revisará y confirmará tu cita.',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 4),
              ),
            );
            Navigator.popUntil(context, (route) => route.isFirst);
          }
          if (state is CitaError) {
            setState(() => _subiendoQr = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CitaLoading) setState(() => _subiendoQr = true);
          if (state is! CitaLoading) setState(() => _subiendoQr = false);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner informativo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B5C8).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF00B5C8).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF00B5C8),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '¡Tu cita fue registrada!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Para confirmarla necesitas realizar un depósito de Bs. ${_adelantoMonto.toStringAsFixed(0)} y subir el comprobante.',
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // QR de pago
              const Text(
                'Escanea el QR para pagar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 12),
              if (_normalizarLinkImagen(_qrLink) != null)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.network(
                      _normalizarLinkImagen(_qrLink)!,
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const SizedBox(
                              width: 220,
                              height: 220,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                            width: 220,
                            height: 220,
                            child: Center(
                              child: Icon(
                                Icons.qr_code_2,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                    ),
                  ),
                )
              else
                Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Text(
                        'QR no disponible',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 28),

              // Subir comprobante
              const Text(
                'Sube tu comprobante de pago',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Acepta imágenes (JPG, PNG) o PDF.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _seleccionarComprobante,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _archivoBytes != null
                          ? const Color(0xFF8DC63F)
                          : Colors.grey.shade300,
                      width: _archivoBytes != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _archivoBytes != null
                            ? Icons.check_circle
                            : Icons.upload_file_outlined,
                        color: _archivoBytes != null
                            ? const Color(0xFF8DC63F)
                            : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _archivoNombre ?? 'Toca para seleccionar archivo',
                          style: TextStyle(
                            color: _archivoBytes != null
                                ? Colors.black87
                                : Colors.grey,
                            fontWeight: _archivoBytes != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_archivoBytes == null || _subiendoQr)
                      ? null
                      : _subirComprobante,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8DC63F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _subiendoQr
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enviar comprobante',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text(
                    'Lo haré más tarde',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
