import 'package:flutter/material.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/features/historial/domain/entities/nota_plantilla.dart';
import 'nota_adjunto_chip.dart';

/// Tarjeta blanca con una sección por campo de la plantilla activa, más el
/// pie de adjuntos. Ocupa el alto restante de la pantalla con scroll
/// interno.
class NotaSeccionEditor extends StatelessWidget {
  final NotaPlantilla plantilla;
  final Map<String, TextEditingController> controllers;
  final Map<String, FocusNode> focusNodes;
  final List<AdjuntoPendiente> adjuntos;
  final VoidCallback onAdjuntar;
  final void Function(int index) onQuitarAdjunto;

  const NotaSeccionEditor({
    super.key,
    required this.plantilla,
    required this.controllers,
    required this.focusNodes,
    required this.adjuntos,
    required this.onAdjuntar,
    required this.onQuitarAdjunto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: plantilla.secciones.length,
              separatorBuilder: (_, _) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final seccion = plantilla.secciones[index];
                return _SeccionCampo(
                  seccion: seccion,
                  controller: controllers[seccion.id]!,
                  focusNode: focusNodes[seccion.id]!,
                );
              },
            ),
          ),
          const Divider(height: 25, thickness: 1, color: Color(0xFFF0F1F2)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < adjuntos.length; i++)
                NotaAdjuntoChip(
                  nombre: adjuntos[i].nombre,
                  onQuitar: () => onQuitarAdjunto(i),
                ),
              NotaAdjuntarChip(onTap: onAdjuntar),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeccionCampo extends StatefulWidget {
  final SeccionDef seccion;
  final TextEditingController controller;
  final FocusNode focusNode;

  const _SeccionCampo({
    required this.seccion,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<_SeccionCampo> createState() => _SeccionCampoState();
}

class _SeccionCampoState extends State<_SeccionCampo> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tieneTexto = widget.controller.text.trim().isNotEmpty;
    final activa = widget.focusNode.hasFocus || tieneTexto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.seccion.etiqueta.isNotEmpty)
          Text(
            widget.seccion.etiqueta.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.06 * 12,
              color: activa ? AppColors.teal : const Color(0xFFC9CCD0),
            ),
          ),
        if (widget.seccion.etiqueta.isNotEmpty) const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          maxLines: null,
          minLines: 2,
          style: const TextStyle(fontSize: 15, height: 1.55, color: AppColors.ink),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            hintText: 'Toca para dictar o escribir…',
            hintStyle: TextStyle(fontSize: 15, color: Color(0xFFB4B8BC)),
          ),
        ),
      ],
    );
  }
}
