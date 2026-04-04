import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelExportService {
  Future<void> exportTransactions(List<Map<String, dynamic>> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Header
    sheetObject.appendRow([
      "Date","Description","Debit","Credit"
    ]);

    // Data
    for (var item in data) {
      sheetObject.appendRow([
        item['date'].toString(),
        item['description'].toString(),
        item['debit'].toString(),
        item['credit'].toString(),
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/report.xlsx";

    final fileBytes = excel.save();
    final file = File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
  }
}