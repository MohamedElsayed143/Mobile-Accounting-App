import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/journal_entry.dart';
import 'package:easy_localization/easy_localization.dart';

class AddEntryDialog extends StatefulWidget {
  final List<Account> accounts;
  final Function(JournalEntry) onSave;

  const AddEntryDialog({
    super.key,
    required this.accounts,
    required this.onSave,
  });

  @override
  State<AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog> {
  final TextEditingController _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<TransactionLine> _lines = [];

  double get totalDebit => _lines.fold(0, (sum, item) => sum + item.debit);
  double get totalCredit => _lines.fold(0, (sum, item) => sum + item.credit);
  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.01 && _lines.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _addLine();
    _addLine();
  }

  void _addLine() {
    setState(() {
      _lines.add(TransactionLine(
        accountId: widget.accounts.isNotEmpty ? widget.accounts.first.id ?? '' : '',
        debit: 0.0,
        credit: 0.0,
        memo: '',
      ));
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_new_journal_entry'.tr()),
        actions: [
          IconButton(
            onPressed: isBalanced
                ? () {
                    final entry = JournalEntry(
                      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                      reference: 'JV-${DateTime.now().millisecondsSinceEpoch}',
                      description: _descController.text,
                      lines: _lines,
                    );
                    Navigator.pop(context);
                    widget.onSave(entry);
                  }
                : null,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'description'.tr()),
            ),
            const SizedBox(height: 16),
            ..._lines.asMap().entries.map((e) => _buildLineItem(e.key, e.value)),
            TextButton.icon(onPressed: _addLine, icon: Icon(Icons.add), label: Text('add_row'.tr())),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(int index, TransactionLine line) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: line.accountId.isNotEmpty ? line.accountId : null,
              items: widget.accounts.map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.name))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _lines[index] = _lines[index].copyWithRepo(accountId: val));
              },
            ),
            Row(
              children: [
                Expanded(child: TextFormField(initialValue: line.debit.toString(), keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'debit'.tr()), onChanged: (v) => setState(() => _lines[index] = _lines[index].copyWithRepo(debit: double.tryParse(v) ?? 0)))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(initialValue: line.credit.toString(), keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'credit'.tr()), onChanged: (v) => setState(() => _lines[index] = _lines[index].copyWithRepo(credit: double.tryParse(v) ?? 0)))),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeLine(index)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension LineMapper on TransactionLine {
  TransactionLine copyWithRepo({String? accountId, double? debit, double? credit}) {
    return TransactionLine(
      id: id,
      entryId: entryId,
      accountId: accountId ?? this.accountId,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      memo: memo,
    );
  }
}
