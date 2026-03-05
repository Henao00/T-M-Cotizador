import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/cotizacion.dart';

class PdfService {
  static final _copFmt =
      NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
  static final _dateFmt = DateFormat('dd/MM/yyyy', 'es_CO');

  static Future<void> printCotizacion(Cotizacion c) async {
    final pdf = pw.Document();

    final accentColor = PdfColor.fromHex('F5A623');
    final darkColor = PdfColor.fromHex('0F1117');
    final grayColor = PdfColor.fromHex('9AA0B8');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: darkColor,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('T&M',
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                          )),
                      pw.SizedBox(height: 4),
                      pw.Text('Construcción · Porones',
                          style: pw.TextStyle(
                              fontSize: 12, color: PdfColors.white)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('COTIZACIÓN',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                          )),
                      pw.Text('#${c.numero.toString().padLeft(4, '0')}',
                          style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white)),
                      pw.SizedBox(height: 4),
                      pw.Text(_dateFmt.format(c.fecha),
                          style:
                              pw.TextStyle(fontSize: 11, color: PdfColors.white)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 28),

            // Plancha info
            pw.Text('DETALLE DE LA PLANCHA',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: grayColor,
                    letterSpacing: 1.5)),
            pw.SizedBox(height: 10),

            if (c.m2 > 0) ...[
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('F5F5F5'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('📐  Área de la plancha',
                              style: pw.TextStyle(fontSize: 11, color: grayColor)),
                          pw.Text('${c.m2} m²',
                              style: pw.TextStyle(
                                  fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('📏  Grosor del porón',
                              style: pw.TextStyle(fontSize: 11, color: grayColor)),
                          pw.Text('${c.alturaPoron} m  (${(c.alturaPoron * 100).toStringAsFixed(0)} cm)',
                              style: pw.TextStyle(
                                  fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('📦  Volumen estimado',
                              style: pw.TextStyle(fontSize: 11, color: grayColor)),
                          pw.Text(
                              '${c.m3Calculado.toStringAsFixed(2)} m³',
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: accentColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
            ],

            // Table header
            pw.Text('RESUMEN DE COSTOS',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: grayColor,
                    letterSpacing: 1.5)),
            pw.SizedBox(height: 10),

            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: darkColor),
                  children: [
                    _cell('Descripción', isHeader: true),
                    _cell('Cantidad', isHeader: true),
                    _cell('Precio Unit.', isHeader: true),
                    _cell('Subtotal', isHeader: true),
                  ],
                ),
                if (c.m2 > 0)
                  pw.TableRow(
                    children: [
                      _cell('Metro cuadrado (m²)'),
                      _cell('${c.m2} m²'),
                      _cell(_copFmt.format(c.precioM2)),
                      _cell(_copFmt.format(c.subTotalM2)),
                    ],
                  ),
                if (c.m3 > 0)
                  pw.TableRow(
                    children: [
                      _cell('Metro cúbico (m³)'),
                      _cell('${c.m3} m³'),
                      _cell(_copFmt.format(c.precioM3)),
                      _cell(_copFmt.format(c.subTotalM3)),
                    ],
                  ),
              ],
            ),

            // Total row
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: const pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(8),
                  bottomRight: pw.Radius.circular(8),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL A PAGAR',
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: darkColor)),
                  pw.Text(_copFmt.format(c.total),
                      style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: darkColor)),
                ],
              ),
            ),

            if (c.notas.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text('NOTAS',
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: grayColor,
                      letterSpacing: 1.5)),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('EEEEEE')),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(c.notas, style: const pw.TextStyle(fontSize: 12)),
              ),
            ],

            pw.Spacer(),

            // Footer
            pw.Divider(color: PdfColor.fromHex('EEEEEE')),
            pw.SizedBox(height: 6),
            pw.Text(
              'Cotización generada por T&M · Todos los precios en pesos colombianos (COP)',
              style: pw.TextStyle(fontSize: 9, color: grayColor),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'TM_Cotizacion_${c.numero.toString().padLeft(4, '0')}.pdf',
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: isHeader ? 10 : 12,
            fontWeight:
                isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHeader ? PdfColors.white : PdfColors.black,
          ),
        ),
      );
}
