import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../data/datasources/historial_remote_datasource.dart';
import '../../data/repositories/historial_repository_impl.dart';
import '../../domain/entities/link_archivo.dart';
import '../../domain/entities/nota_evolucion.dart';
import '../../domain/usecases/obtener_historial.dart';
import '../../domain/usecases/obtener_mi_historial.dart';
import '../../domain/usecases/agregar_nota.dart';
import '../../domain/usecases/agregar_link.dart';
import '../../domain/usecases/subir_archivo_drive.dart';
import '../bloc/historial_bloc.dart';
import '../bloc/historial_event.dart';
import '../bloc/historial_state.dart';

class MiHistorialPage extends StatefulWidget {
  const MiHistorialPage({super.key});

  @override
  State<MiHistorialPage> createState() => _MiHistorialPageState();
}

class _MiHistorialPageState extends State<MiHistorialPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClientProvider.instance;
    final datasource = HistorialRemoteDatasource(apiClient);
    final repository = HistorialRepositoryImpl(datasource);

    return BlocProvider(
      create: (_) => HistorialBloc(
        obtenerHistorialUseCase: ObtenerHistorialUseCase(repository),
        obtenerMiHistorialUseCase: ObtenerMiHistorialUseCase(repository),
        agregarNotaUseCase: AgregarNotaUseCase(repository),
        agregarLinkUseCase: AgregarLinkUseCase(repository),
        subirArchivoDriveUseCase: SubirArchivoDriveUseCase(repository),
      )..add(ObtenerMiHistorialEvent()),
      child: _MiHistorialView(tabController: _tabController),
    );
  }
}

class _MiHistorialView extends StatelessWidget {
  final TabController tabController;
  const _MiHistorialView({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Mi Historial',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: const Color(0xFF8DC63F),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'Notas'),
            Tab(icon: Icon(Icons.image_outlined), text: 'Imágenes'),
            Tab(icon: Icon(Icons.videocam_outlined), text: 'Videos'),
          ],
        ),
      ),
      body: BlocBuilder<HistorialBloc, HistorialState>(
        builder: (context, state) {
          if (state is HistorialLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }

          if (state is HistorialError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    state.mensaje,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (state is HistorialObtenido) {
            final notas = state.historial.notas;
            final imagenes = notas
                .expand((n) => n.links)
                .where((l) => l.tipo == TipoLink.IMAGEN)
                .toList();
            final videos = notas
                .expand((n) => n.links)
                .where((l) => l.tipo == TipoLink.VIDEO)
                .toList();

            return TabBarView(
              controller: tabController,
              children: [
                _buildNotas(notas),
                _buildGaleria(imagenes, TipoLink.IMAGEN),
                _buildGaleria(videos, TipoLink.VIDEO),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildNotas(List<NotaEvolucion> notas) {
    if (notas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No hay notas en tu historial',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notas.length,
      itemBuilder: (context, index) {
        final nota = notas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Color(0xFF00B5C8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd/MM/yyyy').format(nota.fecha),
                      style: const TextStyle(
                        color: Color(0xFF00B5C8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  nota.detalle,
                  style: const TextStyle(color: Colors.black87, height: 1.5),
                ),
                if (nota.links.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: nota.links.map((link) {
                      final esImagen = link.tipo == TipoLink.IMAGEN;
                      return Chip(
                        avatar: Icon(
                          esImagen
                              ? Icons.image_outlined
                              : Icons.videocam_outlined,
                          size: 16,
                          color: esImagen
                              ? const Color(0xFF00B5C8)
                              : Colors.purple,
                        ),
                        label: Text(
                          link.nombre,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGaleria(List<LinkArchivo> links, TipoLink tipo) {
    if (links.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tipo == TipoLink.IMAGEN
                  ? Icons.image_outlined
                  : Icons.videocam_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              tipo == TipoLink.IMAGEN
                  ? 'No hay imágenes disponibles'
                  : 'No hay videos disponibles',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return GestureDetector(
          onTap: () async {
            final fileId = _extraerFileId(link.link);
            final uri = Uri.parse(
              'https://drive.google.com/file/d/$fileId/view',
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tipo == TipoLink.IMAGEN
                      ? Icons.image_outlined
                      : Icons.videocam_outlined,
                  size: 48,
                  color: tipo == TipoLink.IMAGEN
                      ? const Color(0xFF00B5C8)
                      : Colors.purple,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    link.nombre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.open_in_new, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Abrir',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _extraerFileId(String url) {
    final regex = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }
}
