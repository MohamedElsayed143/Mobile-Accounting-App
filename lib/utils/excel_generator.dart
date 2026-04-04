 import 'package:excel/excel.dart';

class ExcelGenerator {

  static void generateCustomerReport(List<Map<String, dynamic>> data) {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Report'];

    sheet.appendRow(["Date", "Description", "Debit", "Credit", "Balance"]);

    for (var row in data) {
      sheet.appendRow([
        row["date"],
        row["description"],
        row["debit"],
        row["credit"],
        row["balance"],
      ]);
    }

    excel.save(fileName: "report.xlsx");
  }
}