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
    // Debit is positive, Credit is negative (Simplified for this view)
    final bool isDebit = account.balance >= 0;
    final Color balanceColor = isDebit ? Colors.green[700]! : Colors.red[700]!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Balance on the LEFTSIDE (trailing in LTR, but leading in RTL if we want it on the left)
        // Since the app is forced to RTL, 'leading' is on the right, 'trailing' is on the left.
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.balance.abs().toStringAsFixed(2),
              style: TextStyle(
                color: balanceColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              isDebit ? 'مدين' : 'دائن',
              style: TextStyle(
                color: balanceColor.withAlpha((0.7 * 255).toInt()),
                fontSize: 10,
              ),
            ),
          ],
        ),
        title: Text(
          account.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'كود: ${account.code}',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        // Avatar on the RIGHTSIDE (leading in RTL context)
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
          foregroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            account.code.isNotEmpty ? account.code[0] : 'أ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
