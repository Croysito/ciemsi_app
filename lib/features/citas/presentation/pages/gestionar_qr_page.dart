import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/google_auth_service.dart';
import '../bloc/cita_bloc.dart';
import '../bloc/cita_event.dart';
import '../bloc/cita_state.dart';

class GestionarQrPage extends StatefulWidget {
  const GestionarQrPage({super.key});

  @override
  State<GestionarQrPage> createState() => _GestionarQrPageState();
}

class _GestionarQrPageState extends State<GestionarQrPage> {
  final _linkController = TextEditingController();
  String? _qrActual;
  double _monto = 50;

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
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _subirImagenQr() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.first;
    final extension = file.extension?.toLowerCase() ?? 'jpg';
    final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Autenticando con Google...'),
        backgroundColor: Color(0xFF00B5C8),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final tokens = await GoogleAuthService.obtenerTokens();
      if (tokens == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticación cancelada'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (!mounted) return;
      context.read<CitaBloc>().add(
        SubirQrPagoImagenEvent(
          bytes: file.bytes!.toList(),
          fileName: file.name,
          mimeType: mimeType,
          tokens: tokens,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'QR de Pago',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<CitaBloc, CitaState>(
        listener: (context, state) {
          if (state is QrPagoCargado) {
            setState(() {
              _qrActual = state.qrLink;
              _monto = state.adelantoMonto;
              _linkController.text = state.qrLink ?? '';
            });
          }
          if (state is QrPagoActualizado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<CitaBloc>().add(ObtenerQrPagoEvent());
          }
          if (state is CitaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // QR actual
              const Text(
                'QR actual',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: _normalizarLinkImagen(_qrActual) != null
                      ? Image.network(
                          _normalizarLinkImagen(_qrActual)!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, e, stack) => const SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: Icon(
                                Icons.qr_code_2,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: Text(
                              'Sin QR configurado',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Monto adelanto: Bs. ${_monto.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              const SizedBox(height: 28),

              // Actualizar link
              const Text(
                'Actualizar link del QR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sube la imagen directamente, o pega el link de Google Drive.',
                style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 12),
              BlocBuilder<CitaBloc, CitaState>(
                builder: (context, state) {
                  final cargando = state is CitaLoading;
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: cargando ? null : _subirImagenQr,
                      icon: const Icon(
                        Icons.upload_file,
                        color: Color(0xFF8DC63F),
                      ),
                      label: const Text(
                        'Subir imagen del QR',
                        style: TextStyle(color: Color(0xFF8DC63F)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8DC63F)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'o pega el link',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Link del QR (Google Drive)',
                  labelStyle: const TextStyle(color: Color(0xFF00B5C8)),
                  prefixIcon: const Icon(Icons.link, color: Color(0xFF00B5C8)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF00B5C8),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              BlocBuilder<CitaBloc, CitaState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is CitaLoading
                          ? null
                          : () {
                              final link = _normalizarLinkImagen(
                                _linkController.text,
                              );
                              if (link == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ingresa el link del QR'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              context.read<CitaBloc>().add(
                                ActualizarQrPagoEvent(link),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B5C8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state is CitaLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Guardar QR',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
