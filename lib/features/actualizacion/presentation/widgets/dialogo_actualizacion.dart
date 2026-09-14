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
class DialogoActualizacion extends StatelessWidget {
  const DialogoActualizacion({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActualizacionBloc, ActualizacionState>(
      builder: (context, state) {
        if (state is ActualizacionDisponible) {
          return _dialogoDisponible(context, state.version);
        }
        if (state is ActualizacionDescargando) {
          return _dialogoDescargando(state.version, state.progreso);
        }
        if (state is ActualizacionListaParaInstalar) {
          return _dialogoListaParaInstalar(context, state.version);
        }
        if (state is ActualizacionError) {
          return _dialogoError(context, state.version, state.mensaje);
        }
        // Se cerró de este lado (ActualizacionInicial): no queda nada
        // que mostrar, cerramos el diálogo si sigue abierto.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        });
        return const SizedBox.shrink();
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
            Navigator.of(context).pop();
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
          onPressed: () => Navigator.of(context).pop(),
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
            Navigator.of(context).pop();
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
