import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_bloc.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_event.dart';
import 'package:ciemsi_app/features/pagos/presentation/bloc/pago_state.dart';
import 'package:ciemsi_app/features/suministros/presentation/bloc/suministro_bloc.dart';
import 'package:ciemsi_app/features/suministros/presentation/pages/inventario_page.dart';
import 'package:ciemsi_app/features/traslados/presentation/bloc/traslado_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/usuario.dart';

/// Pestaña "Inventario" del home. Si ya hay ciudad seleccionada muestra el
/// inventario de esa ciudad; si no (rol Doctora), muestra el selector de ciudad.
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
    if (ciudadId != null && ciudadNombre != null) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: suministroBloc),
          BlocProvider.value(value: trasladoBloc),
        ],
        child: InventarioPage(
          ciudadId: ciudadId!,
          ciudadNombre: ciudadNombre!,
          onMenuTap: onMenuTap,
          usuario: usuario,
        ),
      );
    }

    // Doctora: selector de ciudad
    return _SelectorCiudadInventario(
      onMenuTap: onMenuTap,
      onSeleccionada: onCiudadSeleccionada,
    );
  }
}

class _SelectorCiudadInventario extends StatefulWidget {
  final VoidCallback onMenuTap;
  final void Function(int, String) onSeleccionada;

  const _SelectorCiudadInventario({
    required this.onMenuTap,
    required this.onSeleccionada,
  });

  @override
  State<_SelectorCiudadInventario> createState() =>
      _SelectorCiudadInventarioState();
}

class _SelectorCiudadInventarioState extends State<_SelectorCiudadInventario> {
  List<Map<String, dynamic>> _ciudades = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    context.read<PagoBloc>().add(CargarCiudadesPagoEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PagoBloc, PagoState>(
      listener: (context, state) {
        if (state is CiudadesPagoCargadas) {
          setState(() {
            _ciudades = state.ciudades;
            _cargando = false;
          });
        } else if (state is PagoError) {
          setState(() => _cargando = false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: widget.onMenuTap,
          ),
          title: const Text(
            'Inventario',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF00B5C8),
        ),
        body: _cargando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Selecciona una ciudad',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _ciudades.length,
                      itemBuilder: (_, i) {
                        final c = _ciudades[i];
                        final id = c['id'] is int
                            ? c['id'] as int
                            : int.tryParse(c['id'].toString());
                        final nombre =
                            c['nombreCiudad']?.toString() ?? 'Sin nombre';
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.location_city_outlined,
                              color: Color(0xFF00B5C8),
                            ),
                            title: Text(nombre),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: id != null
                                ? () => widget.onSeleccionada(id, nombre)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
