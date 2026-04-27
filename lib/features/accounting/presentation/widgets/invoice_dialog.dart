import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';

class InvoiceDialog extends StatefulWidget {
  final int accountId;
  final InvoiceType type;
  final Function(Invoice) onSave;

  const InvoiceDialog({
    super.key,
    required this.accountId,
    required this.type,
    required this.onSave,
  });

  @override
  State<InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<InvoiceDialog> {
  final TextEditingController _customerController = TextEditingController();
  final List<InvoiceItem> _items = [];
  DateTime _selectedDate = DateTime.now();

  double get grandTotal => _items.fold(0, (sum, item) => sum + item.total);

  void _addItem() {
    setState(() {
      _items.add(const InvoiceItem(description: '', quantity: 1, price: 0.0));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _addItem(); // Start with one item
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.type == InvoiceType.sale ? 'فاتورة بيع جديدة' : 'فاتورة شراء جديدة';
    final Color themeColor = widget.type == InvoiceType.sale ? Colors.teal : Colors.blueGrey;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: themeColor,
        actions: [
          IconButton(
            onPressed: _items.isNotEmpty && _customerController.text.isNotEmpty
                ? () {
                    final invoice = Invoice(
                      accountId: widget.accountId,
                      invoiceNumber: '${DateTime.now().millisecondsSinceEpoch}',
                      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                      customerName: _customerController.text,
                      items: _items,
                      type: widget.type,

                    );
                    widget.onSave(invoice);
                    Navigator.pop(context);
                  }
                : null,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _customerController,
                      decoration: InputDecoration(
                        labelText: widget.type == InvoiceType.sale ? 'اسم العميل' : 'اسم المورد',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: Text('التاريخ: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الأصناف والخدمات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة صنف'),
                ),
              ],
            ),
            const Divider(),

            // Items List
            ..._items.asMap().entries.map((itemEntry) {
              int index = itemEntry.key;
              return _buildItemRow(index);
            }),

            const SizedBox(height: 100), // Space for Sticky Total
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('الإجمالي النهائي', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              '${grandTotal.toStringAsFixed(2)} ج.م',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(int index) {
    final item = _items[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'الوصف / الصنف', isDense: true),
                    onChanged: (val) => setState(() => _items[index] = InvoiceItem(description: val, quantity: item.quantity, price: item.price)),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الكمية', isDense: true),
                    onChanged: (val) {
                      double qty = double.tryParse(val) ?? 1.0;
                      setState(() => _items[index] = InvoiceItem(description: item.description, quantity: qty, price: item.price));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: '0',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'السعر', isDense: true),
                    onChanged: (val) {
                      double price = double.tryParse(val) ?? 0.0;
                      setState(() => _items[index] = InvoiceItem(description: item.description, quantity: item.quantity, price: price));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    item.total.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
