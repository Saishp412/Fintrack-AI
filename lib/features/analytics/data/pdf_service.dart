import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import '../../transactions/domain/transaction_model.dart';

class PdfService {
  static Future<void> generateAndPrintMonthlyReport({
    required double income,
    required double expense,
    required List<TransactionModel> transactions,
    String? aiSummary,
  }) async {
    try {
      final robotoFont = await PdfGoogleFonts.robotoRegular();
      final robotoBold = await PdfGoogleFonts.robotoBold();

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: robotoFont,
          bold: robotoBold,
        ),
      );

      // Brand Colors
      final primaryColor = PdfColor.fromHex('#6C63FF');
      final secondaryColor = PdfColor.fromHex('#03DAC6');
      final successColor = PdfColor.fromHex('#00C853');
      final errorColor = PdfColor.fromHex('#D50000');
      final surfaceColor = PdfColor.fromHex('#F5F5F5');
      final textColor = PdfColor.fromHex('#1A1A1A');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) {
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'FinTrack AI',
                          style: pw.TextStyle(
                            color: primaryColor,
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Smart Financial Analytics',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Monthly Report',
                      style: pw.TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(color: secondaryColor, thickness: 2),
                pw.SizedBox(height: 20),
              ],
            );
          },
          build: (pw.Context context) {
            return [
              pw.Text(
                'Financial Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                padding: const pw.EdgeInsets.all(20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryColumn('Total Income', income, successColor),
                    pw.Container(width: 1, height: 40, color: PdfColors.grey400),
                    _buildSummaryColumn('Total Expense', expense, errorColor),
                    pw.Container(width: 1, height: 40, color: PdfColors.grey400),
                    _buildSummaryColumn('Net Balance', income - expense, (income - expense) >= 0 ? successColor : errorColor),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              if (aiSummary != null && aiSummary.isNotEmpty) ...[
                // AI Summary Section
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F6F5FF'), // roughly 5% opacity of primary
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColor.fromHex('#DFDBFF')), // roughly 20% opacity of primary
                  ),
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text(
                            '✨ AI Financial Overview',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ]
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        aiSummary,
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey800,
                          lineSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),
              ],
              
              pw.Text(
                'Transaction History',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 16),
              
              if (transactions.isEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Center(
                    child: pw.Text(
                      'No transactions recorded this month.',
                      style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 14),
                    ),
                  ),
                )
              else
                pw.TableHelper.fromTextArray(
                  context: context,
                  border: null,
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E8E6FF'), // 10% opacity of primary color
                    borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
                  ),
                  headerHeight: 40,
                  cellHeight: 35,
                  headerStyle: pw.TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: pw.TextStyle(
                    color: textColor,
                    fontSize: 11,
                  ),
                  rowDecoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
                  ),
                  headers: ['Date', 'Category', 'Type', 'Amount (INR)'],
                  data: transactions.map((tx) {
                    return [
                      '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}',
                      tx.category,
                      tx.type.toUpperCase(),
                      tx.amount.toStringAsFixed(2),
                    ];
                  }).toList(),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.center,
                    3: pw.Alignment.centerRight,
                  },
                ),
            ];
          },
          footer: (context) {
            return pw.Column(
              children: [
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Generated by FinTrack AI on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
                    ),
                    pw.Text(
                      'Page ${context.pageNumber} of ${context.pagesCount}',
                      style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'FinTrack_Monthly_Report.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  static pw.Widget _buildSummaryColumn(String title, double amount, PdfColor amountColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(
            color: PdfColors.grey700,
            fontSize: 12,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          '₹${amount.toStringAsFixed(0)}',
          style: pw.TextStyle(
            color: amountColor,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
