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
  // الطرف المختار (عميل أو مورد)
  Customer? _selectedCustomer;
  Supplier? _selectedSupplier;
  DateTime _selectedDate = DateTime.now();

  // أصناف الفاتورة
  final List<_InvoiceLine> _lines = [];

  bool get _isSale => widget.type == InvoiceType.sale;
  Color get _themeColor => _isSale ? const Color(0xFF00897B) : const Color(0xFF1565C0);

  // ─── Validation ──────────────────────────────────────────────
  bool get _partySelected =>
      _isSale ? _selectedCustomer != null : _selectedSupplier != null;

  bool get _hasItems => _lines.isNotEmpty;

  bool get _canSave => _partySelected && _hasItems && _lines.every((l) => l.quantity > 0);

  double get _grandTotal => _lines.fold(0, (sum, l) => sum + l.total);

  String get _validationMessage {
    if (!_partySelected) {
      return _isSale
          ? '⚠️ يجب اختيار عميل أولاً قبل حفظ الفاتورة'
          : '⚠️ يجب اختيار مورد أولاً قبل حفظ الفاتورة';
    }
    if (!_hasItems) return '⚠️ أضف صنفاً واحداً على الأقل';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_isSale ? 'فاتورة بيع جديدة' : 'فاتورة شراء جديدة',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Tooltip(
              message: _canSave ? 'حفظ الفاتورة' : _validationMessage,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSave ? Colors.white : Colors.white38,
                  foregroundColor: _canSave ? _themeColor : Colors.white70,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: _canSave ? _save : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_validationMessage),
                      backgroundColor: Colors.red[700],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('حفظ'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // رسالة التحقق إذا كان الطرف غير محدد
          if (!_partySelected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.red[50],
              child: Row(children: [
                Icon(Icons.info_outline, color: Colors.red[700], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isSale ? 'الرجاء اختيار عميل لإتمام الفاتورة' : 'الرجاء اختيار مورد لإتمام الفاتورة',
                    style: TextStyle(color: Colors.red[700], fontSize: 13),
                  ),
                ),
              ]),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── بطاقة الطرف ──────────────────────────────
                  _buildPartyCard(),
                  const SizedBox(height: 12),

                  // ─── التاريخ ──────────────────────────────────
                  _buildDateCard(),
                  const SizedBox(height: 16),

                  // ─── أصناف الفاتورة ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('أصناف الفاتورة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _addLine,
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة صنف'),
                        style: TextButton.styleFrom(foregroundColor: _themeColor),
                      ),
                    ],
                  ),
                  const Divider(),

                  if (_lines.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Column(children: [
                        Icon(Icons.add_shopping_cart, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text('اضغط "إضافة صنف" لبدء الفاتورة',
                            style: TextStyle(color: Colors.grey[400])),
                      ]),
                    ),

                  ..._lines.asMap().entries.map((e) => _buildLineCard(e.key, e.value)),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ─── شريط الإجمالي ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _themeColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: _themeColor.withValues(alpha: 0.3), blurRadius: 12)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('الإجمالي النهائي', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('${_grandTotal.toStringAsFixed(2)} ج.م',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ]),
                Text('${_lines.length} صنف', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: _partySelected ? _themeColor.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(_isSale ? Icons.person : Icons.store, color: _themeColor, size: 20),
              const SizedBox(width: 8),
              Text(
                _isSale ? 'اختيار العميل *' : 'اختيار المورد *',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)),
                child: const Text('مطلوب', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 12),
            if (_isSale)
              DropdownButtonFormField<Customer>(
                value: _selectedCustomer,
                hint: const Text('اختر عميلاً من القائمة'),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                  prefixIcon: const Icon(Icons.person_search),
                ),
                items: widget.customers.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.name),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCustomer = v),
              )
            else
              DropdownButtonFormField<Supplier>(
                value: _selectedSupplier,
                hint: const Text('اختر مورداً من القائمة'),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                  prefixIcon: const Icon(Icons.store_mall_directory),
                ),
                items: widget.suppliers.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.name),
                )).toList(),
                onChanged: (v) => setState(() => _selectedSupplier = v),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: _themeColor),
        title: Text('التاريخ: ${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}'),
        trailing: const Icon(Icons.arrow_drop_down),
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
    );
  }

  Widget _buildLineCard(int index, _InvoiceLine line) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<Product>(
                  value: line.product,
                  hint: const Text('اختر صنفاً', style: TextStyle(fontSize: 13)),
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'الصنف',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  items: widget.products.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text('${p.name} (${p.quantity.toStringAsFixed(0)})', style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (p) => setState(() {
                    _lines[index].product = p;
                    if (p != null) {
                      _lines[index].price = _isSale ? p.sellPrice : p.buyPrice;
                      _lines[index].description = p.name;
                    }
                  }),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => setState(() => _lines.removeAt(index)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: line.quantity.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الكمية',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _lines[index].quantity = double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  key: ValueKey(line.price),
                  initialValue: line.price.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'السعر (ج.م)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _lines[index].price = double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _themeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${line.total.toStringAsFixed(2)}\nج.م',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _themeColor),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _addLine() => setState(() => _lines.add(_InvoiceLine()));

  void _save() {
    final partyName = _isSale ? _selectedCustomer!.name : _selectedSupplier!.name;
    final invoice = Invoice(
      invoiceNumber: DateTime.now().millisecondsSinceEpoch.toString(),
      date: '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      partyName: partyName,
      customerId: _isSale ? _selectedCustomer!.id : null,
      supplierId: !_isSale ? _selectedSupplier!.id : null,
      items: _lines.map((l) => InvoiceItem(
        productId: l.product?.id,
        description: l.description.isEmpty ? (l.product?.name ?? 'صنف') : l.description,
        quantity: l.quantity,
        price: l.price,
      )).toList(),
      type: widget.type,
      accountId: widget.accountId,
    );
    widget.onSave(invoice);
  }
}

class _InvoiceLine {
  Product? product;
  String description = '';
  double quantity = 1;
  double price = 0;
  double get total => quantity * price;
}
