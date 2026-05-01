import 'package:flutter/material.dart';
import 'package:mobile_acc/features/accounting/domain/entities/account.dart';

class DetailsPage extends StatelessWidget {
  final Account account; // استلام كائن الحساب بالكامل

  const DetailsPage({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حساب: ${account.name}'),
        backgroundColor: const Color(0xFF00695C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // عرض رصيد الحساب الحقيقي من قاعدة البيانات
            _buildRealSummaryCard(account),
            const SizedBox(height: 20),
            _buildInfoTile("كود الحساب", account.code),
            const SizedBox(height: 20),
            const Text("الحركات الأخيرة", style: TextStyle(fontWeight: FontWeight.bold)),
            // هنا سنعرض العمليات المرتبطة بهذا الحساب لاحقاً
          ],
        ),
      ),
    );
  }

  Widget _buildRealSummaryCard(Account account) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("الرصيد الحالي"),
            Text(
              "${account.balance.toStringAsFixed(2)} ج.م",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: account.balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      tileColor: Colors.grey.shade100,
    );
  }
}