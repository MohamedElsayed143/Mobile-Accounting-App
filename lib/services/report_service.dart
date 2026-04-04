 import '../models/transaction.dart';

class ReportService {

  List<Map<String, dynamic>> buildCustomerStatement(List<Transaction> data) {
    double balance = 0;

    return data.map((t) {
      balance += (t.debit - t.credit);

      return {
        "date": t.date,
        "description": t.description,
        "debit": t.debit,
        "credit": t.credit,
        "balance": balance,
      };
    }).toList();
  }

  Map<String, double> calculateTotals(List<Transaction> data) {
    double totalDebit = 0;
    double totalCredit = 0;

    for (var t in data) {
      totalDebit += t.debit;
      totalCredit += t.credit;
    }

    return {
      "debit": totalDebit,
      "credit": totalCredit,
    };
  }
}