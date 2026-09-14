import 'package:flutter/material.dart';

import '../controllers/ciudad_color_controller.dart';

/// P3 addendum · Fila de chips de ciudad: es leyenda y encendido/apagado a
/// la vez. Reemplaza al filtro de ciudad de la AppBar — la doctora ve las
/// tres ciudades a la vez y apaga sólo las que no quiere ver por ahora.
class CiudadChipsRow extends StatelessWidget {
  final List<String> ciudades;
  final CiudadColorController colores;
  final ValueChanged<String> onToggle;

  const CiudadChipsRow({
    super.key,
    required this.ciudades,
    required this.colores,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (ciudades.isEmpty) return const SizedBox.shrink();

    final desplazable = ciudades.length > 3;
    final chips = ciudades.map((c) => _chip(c, ancho: desplazable ? null : double.infinity)).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SizedBox(
        height: 34,
        child: desplazable
            ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (context, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => chips[i],
              )
            : Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: chips[i]),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _chip(String ciudad, {double? ancho}) {
    final activa = !colores.estaOculta(ciudad);
    final estilo = colores.estiloPara(ciudad);

    final colorPunto = activa ? estilo.color : CiudadColorController.puntoInactivo;
    final colorTexto = activa ? estilo.colorTexto : CiudadColorController.textoInactivo;
    final colorBorde = activa ? estilo.color : CiudadColorController.bordeInactivo;
    final colorFondo = activa ? estilo.color.withValues(alpha: 0.12) : Colors.white;

    return SizedBox(
      width: ancho,
      child: GestureDetector(
        onTap: () => onToggle(ciudad),
        child: Container(
          height: 34,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colorFondo,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorBorde),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: colorPunto, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  ciudad,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorTexto),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
