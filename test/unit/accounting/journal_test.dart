import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_acc/features/accounting/domain/entities/journal_entry.dart';

void main() {
  group('Journal Entry Validation', () {
    test('Should return true for balanced journal entries', () {
      final entry = JournalEntry(
        date: '2026-03-27',
        reference: 'JV001',
        description: 'Balanced Entry',
        lines: const [
          TransactionLine(accountId: 1, debit: 100.0, credit: 0.0),
          TransactionLine(accountId: 2, debit: 0.0, credit: 100.0),
        ],
      );
      expect(entry.isValid, isTrue);
    });

    test('Should return false for unbalanced journal entries', () {
      final entry = JournalEntry(
        date: '2026-03-27',
        reference: 'JV002',
        description: 'Unbalanced Entry',
        lines: const [
          TransactionLine(accountId: 1, debit: 100.0, credit: 0.0),
          TransactionLine(accountId: 2, debit: 0.0, credit: 50.0),
        ],
      );
      expect(entry.isValid, isFalse);
    });

    test('Should return false for empty journal entries', () {
      final entry = JournalEntry(
        date: '2026-03-27',
        reference: 'JV003',
        description: 'Empty Entry',
        lines: const [],
      );
      expect(entry.isValid, isFalse);
    });
  });
}
