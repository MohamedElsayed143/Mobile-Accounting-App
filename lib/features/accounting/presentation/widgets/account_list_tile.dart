import 'package:flutter/material.dart';
import 'package:mobile_acc/features/accounting/domain/entities/account.dart';

class AccountListTile extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;

  const AccountListTile({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDebit = account.balance >= 0;
    // ألوان أكثر هدوءاً واحترافية
    final Color balanceColor = isDebit ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0.5, // تقليل الظل لجعله Flat ومودرن
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // زوايا أكثر انسيابية
        side: BorderSide(color: Colors.grey.shade200, width: 1), // إطار خفيف جداً
      ),
      child: Container(
        // إضافة خط جانبي ملون لتمييز الحالة فوراً
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: balanceColor, width: 4),
          ),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: balanceColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDebit ? Icons.arrow_downward : Icons.arrow_upward,
              color: balanceColor,
              size: 20,
            ),
          ),
          title: Text(
            account.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF263238),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'كود: ${account.code}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end, // محاذاة لليسار في RTL
            children: [
              Text(
                '${account.balance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: balanceColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  fontFamily: 'Roboto', // الأرقام في Roboto شكلها احترافي أكتر
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: balanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isDebit ? 'مدين' : 'دائن',
                  style: TextStyle(
                    color: balanceColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}