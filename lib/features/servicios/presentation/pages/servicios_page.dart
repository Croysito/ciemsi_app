import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/servicio.dart';
import '../bloc/servicio_bloc.dart';
import '../bloc/servicio_event.dart';
import '../bloc/servicio_state.dart';

class ServiciosPage extends StatefulWidget {
  const ServiciosPage({super.key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServicioBloc>().add(CargarServiciosEvent());
  }

  Future<void> _mostrarFormulario({Servicio? servicio}) async {
    final recargado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ServicioBloc>(),
        child: _FormServicio(servicio: servicio),
      ),
    );
    if (recargado == true && mounted) {
      context.read<ServicioBloc>().add(CargarServiciosEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Servicios',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                context.read<ServicioBloc>().add(CargarServiciosEvent()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00B5C8),
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<ServicioBloc, ServicioState>(
        listener: (context, state) {
          if (state is ServicioError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.mensaje}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ServicioLoading || state is ServicioInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
            );
          }
          if (state is ServiciosCargados) {
            if (state.servicios.isEmpty) {
              return const Center(
                child: Text(
                  'No hay servicios registrados',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: state.servicios.length,
              itemBuilder: (_, i) => _ServicioCard(
                servicio: state.servicios[i],
                onTap: () => _mostrarFormulario(servicio: state.servicios[i]),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _ServicioCard extends StatelessWidget {
  final Servicio servicio;
  final VoidCallback onTap;

  const _ServicioCard({required this.servicio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tieneDoctora = servicio.roles.contains('Doctora');
    final tieneAsistente = servicio.roles.contains('Asistente');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: servicio.estado
                      ? const Color(0xFF00B5C8).withValues(alpha: 0.12)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_services_outlined,
                  color: servicio.estado
                      ? const Color(0xFF00B5C8)
                      : Colors.grey,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            servicio.nombreServicio,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: servicio.estado
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        if (!servicio.estado)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Inactivo',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${servicio.tiempoMin} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (tieneDoctora)
                          _RoleChip(
                            label: 'Doctora',
                            color: const Color(0xFF00B5C8),
                          ),
                        if (tieneDoctora && tieneAsistente)
                          const SizedBox(width: 4),
                        if (tieneAsistente)
                          _RoleChip(
                            label: 'Asistente',
                            color: const Color(0xFF8DC63F),
                          ),
                        if (!tieneDoctora && !tieneAsistente)
                          Text(
                            'Sin rol asignado',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade400,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final Color color;
  const _RoleChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Formulario (bottom sheet) ────────────────────────────────────────────────

class _FormServicio extends StatefulWidget {
  final Servicio? servicio;
  const _FormServicio({this.servicio});

  @override
  State<_FormServicio> createState() => _FormServicioState();
}

class _FormServicioState extends State<_FormServicio> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late int _tiempoMin;
  late bool _estado;
  late bool _rolDoctora;
  late bool _rolAsistente;
  bool _guardando = false;

  bool get _esEdicion => widget.servicio != null;

  @override
  void initState() {
    super.initState();
    final s = widget.servicio;
    _nombreCtrl = TextEditingController(text: s?.nombreServicio ?? '');
    _tiempoMin = s?.tiempoMin ?? 30;
    _estado = s?.estado ?? true;
    _rolDoctora = s?.roles.contains('Doctora') ?? false;
    _rolAsistente = s?.roles.contains('Asistente') ?? false;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  List<String> get _rolesSeleccionados => [
        if (_rolDoctora) 'Doctora',
        if (_rolAsistente) 'Asistente',
      ];

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final datos = <String, dynamic>{
      'nombreServicio': _nombreCtrl.text.trim(),
      'tiempoMin': _tiempoMin,
      'roles': _rolesSeleccionados,
      if (_esEdicion) 'estado': _estado,
    };

    if (_esEdicion) {
      context
          .read<ServicioBloc>()
          .add(ModificarServicioEvent(widget.servicio!, datos));
    } else {
      context.read<ServicioBloc>().add(CrearServicioEvent(datos));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<ServicioBloc, ServicioState>(
      listener: (context, state) {
        if (state is ServicioLoading) {
          setState(() => _guardando = true);
        } else if (state is ServicioOperacionExitosa) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _esEdicion
                    ? 'Servicio actualizado correctamente'
                    : 'Servicio creado correctamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is ServicioError) {
          setState(() => _guardando = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.mensaje}'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          setState(() => _guardando = false);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _esEdicion ? 'Editar Servicio' : 'Nuevo Servicio',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B5C8),
                  ),
                ),
                const SizedBox(height: 20),

                // Nombre
                const Text(
                  'Nombre del servicio',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nombreCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ej: Consulta general',
                    filled: true,
                    fillColor: const Color(0xFFF4F4F4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                // Duración
                const Text(
                  'Duración de la cita',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _tiempoMin,
                      items: [15, 20, 30, 45, 60, 90]
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text('$m minutos'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _tiempoMin = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Roles
                const Text(
                  'Disponible para',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _RolToggle(
                        label: 'Doctora',
                        color: const Color(0xFF00B5C8),
                        seleccionado: _rolDoctora,
                        onTap: () =>
                            setState(() => _rolDoctora = !_rolDoctora),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RolToggle(
                        label: 'Asistente',
                        color: const Color(0xFF8DC63F),
                        seleccionado: _rolAsistente,
                        onTap: () =>
                            setState(() => _rolAsistente = !_rolAsistente),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Estado (solo edición)
                if (_esEdicion) ...[
                  const Text(
                    'Estado',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _RolToggle(
                          label: 'Activo',
                          color: const Color(0xFF8DC63F),
                          seleccionado: _estado,
                          onTap: () => setState(() => _estado = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _RolToggle(
                          label: 'Inactivo',
                          color: Colors.grey,
                          seleccionado: !_estado,
                          onTap: () => setState(() => _estado = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B5C8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _esEdicion ? 'Actualizar' : 'Crear Servicio',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RolToggle extends StatelessWidget {
  final String label;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _RolToggle({
    required this.label,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? color.withValues(alpha: 0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              seleccionado ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: seleccionado ? color : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: seleccionado ? color : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
