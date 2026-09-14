import 'package:flutter/material.dart';

import 'package:ciemsi_app/features/suministros/domain/entities/ciudad_inventario.dart';

/// P4 · Panel inline de traslado — se abre debajo de la fila del
/// suministro, dentro de la misma tarjeta. "Cantidad ≥ 1 y destino ≠
/// origen" es la única regla de habilitación (regla transversal 1: la
/// razón, si no se puede, va en la línea 1 — nunca un snackbar).
class TrasladoInlinePanel extends StatefulWidget {
  final String unidadMedida;
  final int ciudadOrigenId;
  final String ciudadOrigenNombre;
  final double saldoOrigen;
  final int cantidadInicial;
  final int cantidadMaxima;
  final List<CiudadInventario> destinos;
  final int destinoInicialId;
  final String? error;
  final VoidCallback onCerrar;
  final void Function(int cantidad, int destinoId) onCrear;

  const TrasladoInlinePanel({
    super.key,
    required this.unidadMedida,
    required this.ciudadOrigenId,
    required this.ciudadOrigenNombre,
    required this.saldoOrigen,
    required this.cantidadInicial,
    required this.cantidadMaxima,
    required this.destinos,
    required this.destinoInicialId,
    this.error,
    required this.onCerrar,
    required this.onCrear,
  });

  @override
  State<TrasladoInlinePanel> createState() => _TrasladoInlinePanelState();
}

class _TrasladoInlinePanelState extends State<TrasladoInlinePanel> {
  late int _cantidad;
  late int _destinoId;

  static const _tealDark = Color(0xFF00838F);
  static const _rojo = Color(0xFFC62828);

  @override
  void initState() {
    super.initState();
    _cantidad = widget.cantidadInicial.clamp(1, widget.cantidadMaxima > 0 ? widget.cantidadMaxima : 1);
    _destinoId = widget.destinoInicialId;
  }

  bool get _enTope => _cantidad >= widget.cantidadMaxima;
  bool get _puedeCrear => _cantidad >= 1 && _destinoId != widget.ciudadOrigenId;

  String get _nombreDestino =>
      widget.destinos.firstWhere((c) => c.id == _destinoId, orElse: () => widget.destinos.first).nombre;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBFC),
        border: Border.all(color: const Color(0x5900B5C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _linea1(),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _stepper(),
              const SizedBox(width: 8),
              Expanded(child: _destinoField()),
              const SizedBox(width: 8),
              _botonCrear(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _linea1() {
    final tope = widget.error == null && _enTope;
    final color = (widget.error != null || tope) ? _rojo : _tealDark;

    return Row(
      children: [
        Icon(Icons.swap_horiz, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: widget.error != null
              ? Text(widget.error!, style: TextStyle(fontSize: 12, color: color))
              : tope
                  ? Text('${widget.ciudadOrigenNombre} sólo tiene ${widget.cantidadMaxima}',
                      style: TextStyle(fontSize: 12, color: color))
                  : RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 12, color: color),
                        children: [
                          const TextSpan(text: 'Mover '),
                          TextSpan(text: widget.unidadMedida, style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' desde ${widget.ciudadOrigenNombre} (${_formatearSaldo(widget.saldoOrigen)})'),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _stepper() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCDFE2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _botonStepper(Icons.remove, () => setState(() => _cantidad = (_cantidad - 1).clamp(1, widget.cantidadMaxima))),
          SizedBox(
            width: 28,
            child: Text('$_cantidad', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          _botonStepper(
            Icons.add,
            _enTope ? null : () => setState(() => _cantidad = (_cantidad + 1).clamp(1, widget.cantidadMaxima)),
          ),
        ],
      ),
    );
  }

  Widget _botonStepper(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(icon, size: 16, color: onTap == null ? const Color(0xFFC9CCD0) : const Color(0xFF16191C)),
      ),
    );
  }

  Widget _destinoField() {
    return PopupMenuButton<int>(
      initialValue: _destinoId,
      onSelected: (id) => setState(() => _destinoId = id),
      itemBuilder: (context) => widget.destinos
          .map((c) => PopupMenuItem(value: c.id, child: Text(c.nombre)))
          .toList(),
      constraints: const BoxConstraints(minWidth: 160),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDCDFE2)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Text('a ', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            Expanded(
              child: Text(
                _nombreDestino,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF16191C)),
              ),
            ),
            const Icon(Icons.expand_more, size: 18, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }

  Widget _botonCrear() {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: _puedeCrear ? () => widget.onCrear(_cantidad, _destinoId) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B5C8),
          disabledBackgroundColor: const Color(0xFFB6DEE3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('Crear', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  String _formatearSaldo(double saldo) => saldo == saldo.roundToDouble() ? saldo.toStringAsFixed(0) : saldo.toStringAsFixed(1);
}
