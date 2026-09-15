import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Controlador para [MontoMixtoField]: guarda lo que el usuario asignó a
/// efectivo y a QR, y expone la suma de ambos.
class MontoMixtoController {
  final TextEditingController efectivoCtrl;
  final TextEditingController qrCtrl;

  MontoMixtoController({double efectivoInicial = 0, double qrInicial = 0})
      : efectivoCtrl = TextEditingController(
          text: efectivoInicial > 0 ? efectivoInicial.toStringAsFixed(2) : '',
        ),
        qrCtrl = TextEditingController(
          text: qrInicial > 0 ? qrInicial.toStringAsFixed(2) : '',
        );

  double get efectivo =>
      double.tryParse(efectivoCtrl.text.replaceAll(',', '.')) ?? 0;
  double get qr => double.tryParse(qrCtrl.text.replaceAll(',', '.')) ?? 0;
  double get total => efectivo + qr;

  void dispose() {
    efectivoCtrl.dispose();
    qrCtrl.dispose();
  }
}

/// Divide un monto total entre efectivo y QR. Incluye atajos para
/// "todo efectivo" / "todo QR" y avisa si falta o sobra algo por asignar.
class MontoMixtoField extends StatefulWidget {
  final MontoMixtoController controller;
  final double total;
  final VoidCallback? onChanged;

  const MontoMixtoField({
    super.key,
    required this.controller,
    required this.total,
    this.onChanged,
  });

  @override
  State<MontoMixtoField> createState() => _MontoMixtoFieldState();
}

class _MontoMixtoFieldState extends State<MontoMixtoField> {
  final _moneyFmt = NumberFormat('#,##0.00', 'es');

  @override
  void initState() {
    super.initState();
    widget.controller.efectivoCtrl.addListener(_onFieldChanged);
    widget.controller.qrCtrl.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    widget.controller.efectivoCtrl.removeListener(_onFieldChanged);
    widget.controller.qrCtrl.removeListener(_onFieldChanged);
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {});
    widget.onChanged?.call();
  }

  void _setTodoEn(String metodo) {
    if (metodo == 'efectivo') {
      widget.controller.efectivoCtrl.text = widget.total > 0
          ? widget.total.toStringAsFixed(2)
          : '';
      widget.controller.qrCtrl.text = '';
    } else {
      widget.controller.qrCtrl.text = widget.total > 0
          ? widget.total.toStringAsFixed(2)
          : '';
      widget.controller.efectivoCtrl.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final diferencia = double.parse(
      (widget.total - widget.controller.total).toStringAsFixed(2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Método de pago',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller.efectivoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Efectivo (Bs.)',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: widget.controller.qrCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'QR (Bs.)',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            TextButton(
              onPressed: () => _setTodoEn('efectivo'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Todo efectivo', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () => _setTodoEn('qr'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Todo QR', style: TextStyle(fontSize: 12)),
            ),
            const Spacer(),
            if (diferencia.abs() > 0.004)
              Text(
                diferencia > 0
                    ? 'Falta Bs. ${_moneyFmt.format(diferencia)}'
                    : 'Sobra Bs. ${_moneyFmt.format(-diferencia)}',
                style: TextStyle(
                  color: cs.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
