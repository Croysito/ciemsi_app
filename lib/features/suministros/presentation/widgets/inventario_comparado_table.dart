import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ciemsi_app/features/suministros/domain/entities/ciudad_inventario.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/estado_celda.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/inventario_comparado.dart';
import 'traslado_inline_panel.dart';

final _numero = NumberFormat.decimalPattern('es');

/// P4 · La matriz "las tres ciudades a la vez": una tarjeta blanca con una
/// fila de encabezado y una fila por suministro. El traslado se pide desde
/// la fila — no hay FAB de traslado en este modo.
class InventarioComparadoTable extends StatelessWidget {
  final InventarioComparado datos;
  final int? filaAbiertaId;
  final int? ciudadOrigenId;
  final String? errorPanel;
  final void Function(ItemComparado item, CiudadInventario ciudad) onTocarCelda;
  final void Function(ItemComparado item) onTocarSwap;
  final VoidCallback onCerrarPanel;
  final void Function(ItemComparado item, int cantidad, int destinoId) onCrearTraslado;
  final int? ciudadUsuarioId;

  const InventarioComparadoTable({
    super.key,
    required this.datos,
    required this.filaAbiertaId,
    required this.ciudadOrigenId,
    required this.errorPanel,
    required this.onTocarCelda,
    required this.onTocarSwap,
    required this.onCerrarPanel,
    required this.onCrearTraslado,
    required this.ciudadUsuarioId,
  });

  bool get _scrollHorizontal => datos.ciudades.length > 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 3, offset: Offset(0, 1))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _encabezado(),
          for (var i = 0; i < datos.items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF2F3F4)),
            _FilaSuministro(
              item: datos.items[i],
              ciudades: datos.ciudades,
              scrollHorizontal: _scrollHorizontal,
              abierta: filaAbiertaId == datos.items[i].id,
              ciudadOrigenId: ciudadOrigenId,
              ciudadUsuarioId: ciudadUsuarioId,
              errorPanel: errorPanel,
              onTocarCelda: (ciudad) => onTocarCelda(datos.items[i], ciudad),
              onTocarSwap: () => onTocarSwap(datos.items[i]),
              onCerrarPanel: onCerrarPanel,
              onCrearTraslado: (cantidad, destinoId) => onCrearTraslado(datos.items[i], cantidad, destinoId),
            ),
          ],
        ],
      ),
    );
  }

  Widget _encabezado() {
    final columnasCiudad = Row(
      mainAxisSize: MainAxisSize.min,
      children: [for (final c in datos.ciudades) _celdaEncabezadoCiudad(c)],
    );

    return Container(
      color: const Color(0xFFFAFBFB),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text('Suministro', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ),
          if (_scrollHorizontal)
            SizedBox(width: 52.0 * 3, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: columnasCiudad))
          else
            columnasCiudad,
          const SizedBox(width: 22),
        ],
      ),
    );
  }

  Widget _celdaEncabezadoCiudad(CiudadInventario c) {
    return SizedBox(
      width: 52,
      child: Column(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
          const SizedBox(height: 3),
          Text(c.abrev, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF757575))),
        ],
      ),
    );
  }
}

class _FilaSuministro extends StatelessWidget {
  final ItemComparado item;
  final List<CiudadInventario> ciudades;
  final bool scrollHorizontal;
  final bool abierta;
  final int? ciudadOrigenId;
  final int? ciudadUsuarioId;
  final String? errorPanel;
  final void Function(CiudadInventario ciudad) onTocarCelda;
  final VoidCallback onTocarSwap;
  final VoidCallback onCerrarPanel;
  final void Function(int cantidad, int destinoId) onCrearTraslado;

  const _FilaSuministro({
    required this.item,
    required this.ciudades,
    required this.scrollHorizontal,
    required this.abierta,
    required this.ciudadOrigenId,
    required this.ciudadUsuarioId,
    required this.errorPanel,
    required this.onTocarCelda,
    required this.onTocarSwap,
    required this.onCerrarPanel,
    required this.onCrearTraslado,
  });

  CiudadInventario get _origen => ciudades.firstWhere((c) => c.id == ciudadOrigenId, orElse: () => ciudades.first);

  @override
  Widget build(BuildContext context) {
    final celdas = Row(
      mainAxisSize: MainAxisSize.min,
      children: [for (final c in ciudades) _celda(c)],
    );

    return Container(
      color: abierta ? const Color(0xFFF4FBFC) : Colors.transparent,
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.nombreSuministro,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16191C)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.unidadMedida} · umbral ${item.umbral}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  ),
                  if (scrollHorizontal)
                    SizedBox(width: 52.0 * 3, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: celdas))
                  else
                    celdas,
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: onTocarSwap,
                      child: Icon(Icons.swap_horiz, size: 18, color: abierta ? const Color(0xFF00838F) : const Color(0xFFB6BBBF)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (abierta) _panel(),
        ],
      ),
    );
  }

  Widget _celda(CiudadInventario ciudad) {
    final saldo = item.saldoEn(ciudad.id);
    final estado = calcularEstadoCelda(saldo: saldo, umbral: item.umbral);
    final esOrigenAbierto = abierta && ciudadOrigenId == ciudad.id;

    return GestureDetector(
      onTap: saldo > 0 ? () => onTocarCelda(ciudad) : null,
      child: Container(
        width: 52,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: estado.fondo,
          borderRadius: BorderRadius.circular(8),
          border: esOrigenAbierto ? Border.all(color: const Color(0xFF00B5C8), width: 1.5) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_numero.format(saldo), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: estado.colorNumero)),
            if (estado.etiqueta != null)
              Text(estado.etiqueta!, style: TextStyle(fontSize: 9, color: estado.colorNumero)),
          ],
        ),
      ),
    );
  }

  Widget _panel() {
    final origen = _origen;
    final saldoOrigen = item.saldoEn(origen.id);
    final destinos = ciudades.where((c) => c.id != origen.id).toList();

    final destinoMasCorto = destinos
        .where((c) => calcularEstadoCelda(saldo: item.saldoEn(c.id), umbral: item.umbral).esAlerta)
        .fold<CiudadInventario?>(null, (masCorto, c) {
      if (masCorto == null) return c;
      return item.saldoEn(c.id) < item.saldoEn(masCorto.id) ? c : masCorto;
    });
    final destinoInicial = destinoMasCorto ??
        destinos.firstWhere((c) => c.id == ciudadUsuarioId, orElse: () => destinos.first);

    final umbralOrigen = item.umbral;
    final saldoDestinoInicial = item.saldoEn(destinoInicial.id);
    final faltante = (umbralOrigen + 1 - saldoDestinoInicial).ceil();
    final topeOrigen = (saldoOrigen - umbralOrigen).floor();
    final maximo = saldoOrigen.floor().clamp(1, 1 << 30);
    var inicial = topeOrigen > 0 ? faltante.clamp(1, topeOrigen) : 1;
    inicial = inicial.clamp(1, maximo);

    return TrasladoInlinePanel(
      key: ValueKey('panel_${item.id}'),
      unidadMedida: item.unidadMedida,
      ciudadOrigenId: origen.id,
      ciudadOrigenNombre: origen.nombre,
      saldoOrigen: saldoOrigen,
      cantidadInicial: inicial,
      cantidadMaxima: maximo,
      destinos: destinos,
      destinoInicialId: destinoInicial.id,
      error: errorPanel,
      onCerrar: onCerrarPanel,
      onCrear: onCrearTraslado,
    );
  }
}
