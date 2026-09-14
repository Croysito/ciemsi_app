import 'package:flutter/material.dart';

/// P4 · Primera carga: encabezado real + seis filas de bloques grises.
/// Nunca un `CircularProgressIndicator` centrado (regla transversal 2).
class InventarioComparadoSkeleton extends StatelessWidget {
  const InventarioComparadoSkeleton({super.key});

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
          Container(
            color: const Color(0xFFFAFBFB),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Suministro', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                ),
                for (var i = 0; i < 3; i++) const SizedBox(width: 52, child: SizedBox(height: 20)),
                const SizedBox(width: 22),
              ],
            ),
          ),
          for (var i = 0; i < 6; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF2F3F4)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _bloque(width: 120, height: 13),
                          const SizedBox(height: 6),
                          _bloque(width: 80, height: 11),
                        ],
                      ),
                    ),
                    for (var j = 0; j < 3; j++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: _bloque(width: 40, height: 40, margin: const EdgeInsets.only(left: 12)),
                      ),
                    const SizedBox(width: 22),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bloque({required double width, required double height, EdgeInsets? margin}) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(color: const Color(0xFFEDEEEF), borderRadius: BorderRadius.circular(4)),
    );
  }
}
