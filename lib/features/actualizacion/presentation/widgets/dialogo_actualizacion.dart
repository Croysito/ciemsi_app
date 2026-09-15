import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/actualizacion/domain/entities/version_disponible.dart';
import 'package:ciemsi_app/features/actualizacion/presentation/bloc/actualizacion_bloc.dart';
import 'package:ciemsi_app/features/actualizacion/presentation/bloc/actualizacion_event.dart';
import 'package:ciemsi_app/features/actualizacion/presentation/bloc/actualizacion_state.dart';

const _colorAcento = Color(0xFF00B5C8);

/// Diálogo descartable que avisa de una nueva versión disponible, y
/// acompaña la descarga/instalación. Se muestra sobre cualquier pantalla
/// en la que esté el usuario cuando se detecta la actualización.
///
/// No se aloja como ruta del Navigator (no usa showDialog): se inserta en
/// el Overlay raíz para que sobreviva a los pushReplacement/navegaciones
/// que hace el resto de la app (ver main.dart), en vez de ser tapado o
/// reemplazado por ellos.
class DialogoActualizacion extends StatelessWidget {
  const DialogoActualizacion({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActualizacionBloc, ActualizacionState>(
      builder: (context, state) {
        Widget? contenido;
        if (state is ActualizacionDisponible) {
          contenido = _dialogoDisponible(context, state.version);
        } else if (state is ActualizacionDescargando) {
          contenido = _dialogoDescargando(state.version, state.progreso);
        } else if (state is ActualizacionListaParaInstalar) {
          contenido = _dialogoListaParaInstalar(context, state.version);
        } else if (state is ActualizacionError) {
          contenido = _dialogoError(context, state.version, state.mensaje);
        }

        if (contenido == null) return const SizedBox.shrink();

        return Stack(
          children: [
            const ModalBarrier(dismissible: false, color: Colors.black54),
            Center(child: contenido),
          ],
        );
      },
    );
  }

  AlertDialog _dialogoDisponible(BuildContext context, VersionDisponible v) {
    return AlertDialog(
      icon: const Icon(Icons.system_update, color: _colorAcento, size: 32),
      title: const Text('Nueva versión disponible'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hay una actualización de CIEMSI (v${v.version}) lista para '
              'instalar.',
            ),
            if (v.notas != null && v.notas!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                v.notas!.trim(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<ActualizacionBloc>().add(
              const DescartarActualizacionEvent(),
            );
          },
          child: const Text('Ahora no'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _colorAcento),
          onPressed: () {
            context.read<ActualizacionBloc>().add(
              DescargarActualizacionEvent(v),
            );
          },
          child: const Text('Actualizar'),
        ),
      ],
    );
  }

  AlertDialog _dialogoDescargando(VersionDisponible v, double progreso) {
    return AlertDialog(
      title: const Text('Descargando actualización'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progreso > 0 ? progreso : null,
            color: _colorAcento,
          ),
          const SizedBox(height: 12),
          Text('${(progreso * 100).clamp(0, 100).toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  AlertDialog _dialogoListaParaInstalar(
    BuildContext context,
    VersionDisponible v,
  ) {
    return AlertDialog(
      icon: const Icon(Icons.download_done, color: _colorAcento, size: 32),
      title: const Text('Descarga completa'),
      content: const Text(
        'Se abrió el instalador de Android. Si no aparece, tocá "Instalar".',
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<ActualizacionBloc>().add(
              const DescartarActualizacionEvent(),
            );
          },
          child: const Text('Cerrar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _colorAcento),
          onPressed: () {
            context.read<ActualizacionBloc>().add(
              const InstalarActualizacionEvent(),
            );
          },
          child: const Text('Instalar'),
        ),
      ],
    );
  }

  AlertDialog _dialogoError(
    BuildContext context,
    VersionDisponible v,
    String mensaje,
  ) {
    return AlertDialog(
      icon: const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
      title: const Text('No se pudo actualizar'),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () {
            context.read<ActualizacionBloc>().add(
              const DescartarActualizacionEvent(),
            );
          },
          child: const Text('Cerrar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _colorAcento),
          onPressed: () {
            context.read<ActualizacionBloc>().add(
              DescargarActualizacionEvent(v),
            );
          },
          child: const Text('Reintentar'),
        ),
      ],
    );
  }
}
