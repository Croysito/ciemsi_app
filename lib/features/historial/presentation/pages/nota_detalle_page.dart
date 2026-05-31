import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/nota_evolucion.dart';
import '../../domain/entities/link_archivo.dart';
import '../bloc/historial_bloc.dart';
import '../bloc/historial_event.dart';
import '../bloc/historial_state.dart';
import '../widgets/bold_markdown_text.dart';
import '../../../../core/services/google_auth_service.dart';

class NotaDetallePage extends StatefulWidget {
  final NotaEvolucion nota;
  const NotaDetallePage({super.key, required this.nota});

  @override
  State<NotaDetallePage> createState() => _NotaDetallePageState();
}

class _NotaDetallePageState extends State<NotaDetallePage> {
  final _linkController = TextEditingController();
  final _nombreController = TextEditingController();
  String _tipoSeleccionado = 'IMAGEN';

  @override
  void dispose() {
    _linkController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  void _mostrarDialogoLink() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<HistorialBloc>(),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agregar Link Manual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del archivo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Link de Google Drive',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tipoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                items: ['IMAGEN', 'VIDEO', 'DRIVE']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipoSeleccionado = v!),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nombreController.text.isEmpty ||
                        _linkController.text.isEmpty) {
                      return;
                    }
                    context.read<HistorialBloc>().add(
                      AgregarLinkEvent(
                        notaId: widget.nota.id,
                        nombre: _nombreController.text.trim(),
                        link: _linkController.text.trim(),
                        tipo: _tipoSeleccionado,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B5C8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _subirArchivoDrive() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final extension = file.extension?.toLowerCase() ?? '';

    // Determinar tipo y mimeType correctos
    String tipo = 'DRIVE';
    String mimeType = 'application/octet-stream';

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        tipo = 'IMAGEN';
        mimeType = 'image/jpeg';
        break;
      case 'png':
        tipo = 'IMAGEN';
        mimeType = 'image/png';
        break;
      case 'mp4':
        tipo = 'VIDEO';
        mimeType = 'video/mp4';
        break;
      case 'mov':
        tipo = 'VIDEO';
        mimeType = 'video/quicktime';
        break;
      case 'pdf':
        tipo = 'DRIVE';
        mimeType = 'application/pdf';
        break;
    }

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticación cancelada'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subiendo archivo a Google Drive...'),
          backgroundColor: Color(0xFF00B5C8),
        ),
      );

      context.read<HistorialBloc>().add(
        SubirArchivoDriveEvent(
          notaId: widget.nota.id,
          tipo: tipo,
          tokens: tokens,
          bytes: file.bytes!.toList(),
          nombre: file.name,
          mimeType: mimeType,
        ),
      );
    } catch (e) {
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
          'Detalle de Nota',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<HistorialBloc, HistorialState>(
        listener: (context, state) {
          if (state is LinkAgregado || state is ArchivoSubido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Archivo agregado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<HistorialBloc>().add(
              ObtenerHistorialEvent(widget.nota.historialId),
            );
          }
          if (state is HistorialError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Obtener links actualizados del estado
          List links = widget.nota.links;
          if (state is HistorialObtenido) {
            final notaActualizada = state.historial.notas
                .where((n) => n.id == widget.nota.id)
                .toList();
            if (notaActualizada.isNotEmpty) {
              links = notaActualizada.first.links;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF00B5C8),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(widget.nota.fecha),
                      style: const TextStyle(
                        color: Color(0xFF00B5C8),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Detalle nota
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BoldMarkdownText(
                      widget.nota.detalle,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botones agregar archivos
                const Text(
                  'Archivos adjuntos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _mostrarDialogoLink,
                        icon: const Icon(Icons.link, color: Color(0xFF00B5C8)),
                        label: const Text(
                          'Link manual',
                          style: TextStyle(color: Color(0xFF00B5C8)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00B5C8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _subirArchivoDrive,
                        icon: const Icon(
                          Icons.upload_file,
                          color: Color(0xFF8DC63F),
                        ),
                        label: const Text(
                          'Subir a Drive',
                          style: TextStyle(color: Color(0xFF8DC63F)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8DC63F)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista de links actualizada
                if (state is HistorialLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
                  )
                else if (links.isNotEmpty)
                  ...links.map((link) => _buildLinkCard(link))
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay archivos adjuntos',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinkCard(LinkArchivo link) {
    IconData icon;
    Color color;

    switch (link.tipo) {
      case TipoLink.IMAGEN:
        icon = Icons.image_outlined;
        color = const Color(0xFF00B5C8);
        break;
      case TipoLink.VIDEO:
        icon = Icons.videocam_outlined;
        color = Colors.purple;
        break;
      case TipoLink.DRIVE:
        icon = Icons.folder_outlined;
        color = const Color(0xFF8DC63F);
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          link.nombre,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          link.tipo.name,
          style: TextStyle(color: color, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, color: Colors.grey),
          onPressed: () async {
            if (link.tipo == TipoLink.VIDEO) {
              // Para videos extraer el fileId y abrir con app de Drive
              final fileId = _extraerFileId(link.link);
              final driveUri = Uri.parse(
                'https://drive.google.com/file/d/$fileId/view',
              );
              if (await canLaunchUrl(driveUri)) {
                await launchUrl(driveUri, mode: LaunchMode.externalApplication);
              }
            } else {
              final uri = Uri.parse(link.link);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          },
        ),
      ),
    );
  }

  String _extraerFileId(String url) {
    final regex = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }
}
