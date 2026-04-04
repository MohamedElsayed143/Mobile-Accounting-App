 
   import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {

  static Future<void> generateCustomerReport(List<Map<String, dynamic>> data) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Table.fromTextArray(
            headers: ["Date", "Description", "Debit", "Credit", "Balance"],
            data: data.map((row) {
              return [
                row["date"],
                row["description"],
                row["debit"].toString(),
                row["credit"].toString(),
                row["balance"].toString(),
              ];
            }).toList(),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
    );
  }
}