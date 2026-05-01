import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/journal_entry.dart';

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
    // Start with 2 empty lines
    _addLine(isDebit: true);
    _addLine(isDebit: false);
  }

  void _addLine({required bool isDebit}) {
    setState(() {
      _lines.add(TransactionLine(
        accountId: widget.accounts.isNotEmpty ? widget.accounts.first.id! : 0,
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
        title: const Text('إضافة قيد يومية جديد'),
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
                    widget.onSave(entry);
                    Navigator.pop(context);
                  }
                : null,
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'حفظ القيد',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header: Description & Date
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'وصف القيد العام',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: Text('تاريخ العملية: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('بنود القيد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton.icon(
                  onPressed: () => _addLine(isDebit: true),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('إضافة سطر'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dynamic Lines
            ..._lines.asMap().entries.map((entry) {
              int index = entry.key;
              TransactionLine line = entry.value;
              return _buildLineItem(index, line);
            }),

            const SizedBox(height: 80), // Space for status bar
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إجمالي مدين: ${totalDebit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Text('إجمالي دائن: ${totalCredit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            isBalanced
                ? const Chip(label: Text('متوازن'), backgroundColor: Colors.greenAccent)
                : const Chip(label: Text('غير متوازن'), backgroundColor: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(int index, TransactionLine line) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    initialValue: line.accountId != 0 ? line.accountId : null,
                    decoration: const InputDecoration(labelText: 'الحساب', isDense: true),
                    items: widget.accounts.map((acc) {
                      return DropdownMenuItem(value: acc.id, child: Text(acc.name, style: const TextStyle(fontSize: 14)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _lines[index] = _lines[index].copyWithRepo(accountId: val));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeLine(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'مدين (Debit)', isDense: true),
                    onChanged: (val) {
                      double debit = double.tryParse(val) ?? 0.0;
                      setState(() => _lines[index] = _lines[index].copyWithRepo(debit: debit, credit: 0.0));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'دائن (Credit)', isDense: true),
                    onChanged: (val) {
                      double credit = double.tryParse(val) ?? 0.0;
                      setState(() => _lines[index] = _lines[index].copyWithRepo(credit: credit, debit: 0.0));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to help with immutability in local state
extension LineMapper on TransactionLine {
  TransactionLine copyWithRepo({int? accountId, double? debit, double? credit}) {
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
