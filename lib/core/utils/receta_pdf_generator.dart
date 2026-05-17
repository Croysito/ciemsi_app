import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';

class RecetaPdfGenerator {
  static const _teal = PdfColor(0, 0.710, 0.784);
  static const _green = PdfColor(0.553, 0.776, 0.247);

  static Future<File> generar({
    required CitaMedica cita,
    required String detalle,
  }) async {
    final doc = pw.Document();

    final logoBytes = await rootBundle.load('assets/images/logo_ciemsi.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final fecha = DateFormat('dd/MM/yyyy').format(cita.fecha);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header(logo),
            pw.SizedBox(height: 20),
            _titulo(),
            pw.SizedBox(height: 20),
            _datosPaciente(cita, fecha),
            pw.SizedBox(height: 24),
            _receta(detalle),
            pw.SizedBox(height: 40),
            _firma(),
            pw.Spacer(),
            _footer(cita),
          ],
        ),
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/receta_cita_${cita.id}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static pw.Widget _header(pw.ImageProvider logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const pw.BoxDecoration(
        color: _teal,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Image(logo, width: 52, height: 52),
          pw.SizedBox(width: 16),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CIEMSI',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Centro Integral de Especialidades Médicas Integradas',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 9),
              ),
              pw.Text(
                'Cochabamba, Bolivia',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _titulo() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'RECETA MÉDICA',
            style: pw.TextStyle(
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
              color: _teal,
              letterSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Container(width: 160, height: 2.5, color: _green),
        ],
      ),
    );
  }

  static pw.Widget _datosPaciente(CitaMedica cita, String fecha) {
    final p = cita.paciente;
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _teal, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DATOS DEL PACIENTE',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _teal,
              letterSpacing: 1.5,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(child: _campo('Nombre', p.nombreCompleto)),
              pw.SizedBox(width: 20),
              pw.Expanded(child: _campo('CI', p.ci)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: _campo(
                  'Edad',
                  p.edad != null ? '${p.edad} años' : '-',
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(child: _campo('Fecha de emisión', fecha)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(child: _campo('Ciudad', cita.ciudad.nombreCiudad)),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _campo('Especialidad', cita.servicio.nombreServicio),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _receta(String detalle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Rp/',
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
            color: _teal,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Text(
            detalle,
            style: const pw.TextStyle(fontSize: 12, lineSpacing: 6),
          ),
        ),
      ],
    );
  }

  static pw.Widget _firma() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 44),
            pw.Container(width: 200, height: 1, color: PdfColors.grey700),
            pw.SizedBox(height: 5),
            pw.Text(
              'Firma y sello del médico',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _footer(CitaMedica cita) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'Esta receta tiene validez de 30 días a partir de la fecha de emisión.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        pw.Center(
          child: pw.Text(
            'N° Cita: ${cita.id}  |  ${cita.ciudad.nombreCiudad}, Bolivia',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
      ],
    );
  }

  static pw.Widget _campo(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
