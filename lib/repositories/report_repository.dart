  import '../models/transaction.dart';

class ReportRepository {

  Future<List<Transaction>> getTransactionsByCustomer(String customerName) async {
    return [
      Transaction(
        id: "1",
        date: "2026-01-01",
        description: "Invoice",
        debit: 1000,
        credit: 0,
        customerName: customerName,
      ),
      Transaction(
        id: "2",
        date: "2026-01-05",
        description: "Payment",
        debit: 0,
        credit: 500,
        customerName: customerName,
      ),
    ];
  }

}