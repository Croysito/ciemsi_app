import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/features/citas/presentation/controllers/paciente_busqueda_controller.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

/// Tarjeta de paciente — el contexto viaja arriba (AppBar) en vez de una
/// tarjeta propia como antes. Dos estados: paciente ya elegido (resumen +
/// lápiz para volver a elegir sin perder fecha/hora) o buscador.
class TarjetaPaciente extends StatelessWidget {
  final PacienteBusquedaController controller;
  final bool puedeCrearPacienteNuevo;
  final TextEditingController buscadorController;
  final Servicio? servicioSeleccionado;
  final List<Servicio> servicios;
  final bool cargandoServicios;
  final String? advertenciaServicio;
  final ValueChanged<Servicio?> onServicioCambiado;
  final VoidCallback onEditar;
  final TextEditingController nombreNuevoController;
  final TextEditingController telefonoNuevoController;
  final bool mostrarEditar;

  const TarjetaPaciente({
    super.key,
    required this.controller,
    required this.puedeCrearPacienteNuevo,
    required this.buscadorController,
    required this.servicioSeleccionado,
    required this.servicios,
    required this.cargandoServicios,
    required this.advertenciaServicio,
    required this.onServicioCambiado,
    required this.onEditar,
    required this.nombreNuevoController,
    required this.telefonoNuevoController,
    this.mostrarEditar = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final paciente = controller.pacienteSeleccionado;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.shadowTarjeta,
          ),
          child: paciente != null
              ? _resumen(context, paciente)
              : _buscador(context),
        );
      },
    );
  }

  Widget _resumen(BuildContext context, dynamic paciente) {
    final nombre = PacienteBusquedaController.nombrePaciente(paciente);
    final ci = (paciente['ci'] ?? '').toString();
    final servicioTxt = servicioSeleccionado == null
        ? 'Elegir servicio'
        : '${servicioSeleccionado!.nombreServicio}, ${servicioSeleccionado!.tiempoMin} min';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.teal,
              child: Text(
                nombre.isNotEmpty ? nombre[0].toUpperCase() : 'P',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF16191C)),
                  ),
                  Text(
                    ci.isNotEmpty ? 'CI $ci · $servicioTxt' : servicioTxt,
                    style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            if (mostrarEditar)
              GestureDetector(
                onTap: onEditar,
                child: const Icon(Icons.edit, size: 20, color: Color(0xFF9E9E9E)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _selectorServicio(),
        if (advertenciaServicio != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  advertenciaServicio!,
                  style: const TextStyle(fontSize: 11, color: AppColors.warning),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buscador(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Elegir paciente',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.teal),
        ),
        const SizedBox(height: 10),
        if (puedeCrearPacienteNuevo) ...[
          SizedBox(
            height: 44,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, icon: Icon(Icons.person_search_outlined), label: Text('Existente')),
                ButtonSegment(value: true, icon: Icon(Icons.person_add_alt_1_outlined), label: Text('Nuevo')),
              ],
              selected: {controller.usarPacienteNuevo},
              onSelectionChanged: (s) => controller.setUsarPacienteNuevo(s.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected) ? Colors.white : AppColors.teal,
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected) ? AppColors.teal : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (controller.cargando)
          const Center(child: CircularProgressIndicator(color: AppColors.teal))
        else if (puedeCrearPacienteNuevo && controller.usarPacienteNuevo)
          _formularioNuevo()
        else
          _typeahead(context),
        const SizedBox(height: 12),
        _selectorServicio(),
      ],
    );
  }

  Widget _typeahead(BuildContext context) {
    return TypeAheadField<dynamic>(
      controller: buscadorController,
      builder: (context, textController, focusNode) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Buscar paciente...',
            prefixIcon: const Icon(Icons.search, color: AppColors.teal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
          ),
        );
      },
      suggestionsCallback: (search) => controller.buscar(search),
      itemBuilder: (context, paciente) {
        final nombre = PacienteBusquedaController.nombrePaciente(paciente);
        final ci = (paciente['ci'] ?? '').toString();
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.teal,
            child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'P', style: const TextStyle(color: Colors.white)),
          ),
          title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(ci.isNotEmpty ? 'CI: $ci' : 'Paciente provisional'),
        );
      },
      onSelected: (paciente) {
        FocusScope.of(context).unfocus();
        buscadorController.text = PacienteBusquedaController.nombrePaciente(paciente);
        controller.seleccionar(paciente);
      },
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No se encontraron pacientes', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _formularioNuevo() {
    return Column(
      children: [
        TextField(
          controller: nombreNuevoController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nombre del paciente',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: telefonoNuevoController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Teléfono',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _selectorServicio() {
    if (cargandoServicios) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderChip),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Servicio>(
          isExpanded: true,
          hint: const Text('Seleccionar servicio'),
          value: servicioSeleccionado,
          items: servicios
              .map((s) => DropdownMenuItem(value: s, child: Text('${s.nombreServicio} (${s.tiempoMin} min)')))
              .toList(),
          onChanged: onServicioCambiado,
        ),
      ),
    );
  }
}
