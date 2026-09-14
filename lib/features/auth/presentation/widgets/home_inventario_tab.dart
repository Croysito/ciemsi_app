import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/pages/inventario_page.dart';
import 'package:ciemsi_app/features/traslados/presentation/bloc/traslado_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/usuario.dart';

/// Pestaña "Inventario" del home. `InventarioPage` ya resuelve la ciudad
/// por sí sola (P4 · modo Comparar no necesita ninguna elegida de
/// antemano, y modo Mi ciudad trae su propio selector para quien puede ver
/// más de una) — este widget sólo pasa las props a través.
class InventarioTab extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onMenuTap;
  final int? ciudadId;
  final String? ciudadNombre;
  final SuministroBloc suministroBloc;
  final TrasladoBloc trasladoBloc;
  final void Function(int, String) onCiudadSeleccionada;

  const InventarioTab({
    super.key,
    required this.usuario,
    required this.onMenuTap,
    required this.ciudadId,
    required this.ciudadNombre,
    required this.suministroBloc,
    required this.trasladoBloc,
    required this.onCiudadSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: suministroBloc),
        BlocProvider.value(value: trasladoBloc),
      ],
      child: InventarioPage(
        ciudadId: ciudadId,
        ciudadNombre: ciudadNombre,
        onMenuTap: onMenuTap,
        usuario: usuario,
        onCiudadSeleccionada: onCiudadSeleccionada,
      ),
    );
  }
}
