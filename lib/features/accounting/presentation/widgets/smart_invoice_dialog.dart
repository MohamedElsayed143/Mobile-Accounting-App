import 'package:flutter/material.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';

class SmartInvoiceDialog extends StatefulWidget {
  final InvoiceType type;
  final List<Customer> customers;
  final List<Supplier> suppliers;
  final List<Product> products;
  final String accountId;
  final Function(Invoice) onSave;

  const SmartInvoiceDialog({
    super.key,
    required this.type,
    required this.customers,
    required this.suppliers,
    required this.products,
    required this.accountId,
    required this.onSave,
  });

  @override
  State<SmartInvoiceDialog> createState() => _SmartInvoiceDialogState();
}

class _SmartInvoiceDialogState extends State<SmartInvoiceDialog> {
  Customer? _selectedCustomer;
  Supplier? _selectedSupplier;
  DateTime _selectedDate = DateTime.now();
  final List<_InvoiceLine> _lines = [];
  bool _isSaving = false;

  bool get _isSale => widget.type == InvoiceType.sale;
  Color get _themeColor => _isSale ? const Color(0xFF00897B) : const Color(0xFF1565C0);

  bool get _partySelected => _isSale ? _selectedCustomer != null : _selectedSupplier != null;
  bool get _hasItems => _lines.isNotEmpty;
  bool get _canSave => _partySelected && _hasItems && _lines.every((l) => l.quantity > 0) && !_isSaving;
  double get _grandTotal => _lines.fold(0, (sum, l) => sum + l.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_isSale ? 'فاتورة بيع جديدة' : 'فاتورة شراء جديدة'),
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _canSave ? () => _save() : null,
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPartyCard(),
                  const SizedBox(height: 12),
                  _buildDateCard(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('أصناف الفاتورة', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(onPressed: _addLine, icon: const Icon(Icons.add), label: const Text('إضافة صنف')),
                    ],
                  ),
                  ..._lines.asMap().entries.map((e) => _buildLineCard(e.key, e.value)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: _themeColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإجمالي: ${_grandTotal.toStringAsFixed(2)} ج.م', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_lines.length} صنف', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isSale
            ? DropdownButtonFormField<Customer>(
                value: _selectedCustomer,
                hint: const Text('اختر عميلاً'),
                items: widget.customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedCustomer = v),
              )
            : DropdownButtonFormField<Supplier>(
                value: _selectedSupplier,
                hint: const Text('اختر مورداً'),
                items: widget.suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (v) => setState(() => _selectedSupplier = v),
              ),
      ),
    );
  }

  Widget _buildDateCard() {
    return Card(
      child: ListTile(
        title: Text('التاريخ: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
          if (date != null) setState(() => _selectedDate = date);
        },
      ),
    );
  }

  Widget _buildLineCard(int index, _InvoiceLine line) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            DropdownButtonFormField<Product>(
              value: line.product,
              hint: const Text('اختر صنفاً'),
              items: widget.products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
              onChanged: (p) => setState(() {
                line.product = p;
                if (p != null) {
                  line.price = _isSale ? p.sellPrice : p.buyPrice;
                  line.description = p.name;
                  line.discount = p.discount;
                }
              }),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextFormField(initialValue: line.quantity.toString(), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الكمية', isDense: true), onChanged: (v) => setState(() => line.quantity = double.tryParse(v) ?? 0))),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('${line.product?.id}_${line.price}'),
                    initialValue: line.price.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'السعر', isDense: true),
                    onChanged: (v) {
                      double newPrice = double.tryParse(v) ?? 0;
                      setState(() {
                        line.price = newPrice;
                        if (line.product != null && line.price > 0) {
                          double buyPrice = line.product!.buyPrice;
                          double sellPrice = _isSale ? line.price : line.product!.sellPrice;
                          if (!_isSale) buyPrice = line.price;
                          
                          if (sellPrice > 0) {
                            line.discount = ((sellPrice - buyPrice) / sellPrice) * 100;
                            if (line.discount < 0) line.discount = 0;
                          }
                        }
                      });
                    }
                  )
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Column(
                    children: [
                      const Text('الخصم', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                      Text('${line.discount.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _lines.removeAt(index))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addLine() => setState(() => _lines.add(_InvoiceLine()));

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _isSaving = true);

    final invoice = Invoice(
      invoiceNumber: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate.toLocal().toString().split(' ')[0],
      partyName: _isSale ? _selectedCustomer!.name : _selectedSupplier!.name,
      customerId: _isSale ? _selectedCustomer!.id : null,
      supplierId: !_isSale ? _selectedSupplier!.id : null,
      items: _lines.map((l) => InvoiceItem(
        productId: l.product?.id,
        description: l.description,
        quantity: l.quantity,
        price: l.price,
        discount: l.discount,
      )).toList(),
      type: widget.type,
      accountId: widget.accountId,
    );

    // ✅ نحفظ أولاً ثم نغلق - لضمان وصول البيانات للـ Stream قبل العودة
    await Future.microtask(() => widget.onSave(invoice));

    if (mounted) Navigator.pop(context);
  }
}

class _InvoiceLine {
  Product? product;
  String description = '';
  double quantity = 1;
  double price = 0;
  double discount = 0;
  double get total => quantity * price;
}
