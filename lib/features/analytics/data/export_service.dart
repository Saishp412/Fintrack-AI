import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html;
import '../../transactions/domain/transaction_model.dart';

class ExportService {
  static void generateAndDownloadCsv(List<TransactionModel> transactions, String filename) {
    // 1. Define CSV Headers
    List<List<dynamic>> rows = [
      ['Date', 'Type', 'Category', 'Amount', 'Notes', 'Trip ID', 'Split With'],
    ];

    // 2. Populate Rows
    for (var tx in transactions) {
      rows.add([
        tx.date.toString().substring(0, 10),
        tx.type,
        tx.category,
        tx.amount.toStringAsFixed(2),
        tx.notes,
        tx.tripId ?? '',
        tx.splitWith ?? '',
      ]);
    }

    // 3. Convert to CSV String
    String csvString = const ListToCsvConverter().convert(rows);

    // 4. Trigger Web Download via Blob
    final bytes = utf8.encode(csvString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$filename.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
