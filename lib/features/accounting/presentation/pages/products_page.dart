import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_cubit.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_state.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<AccountingCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات - كارت الصنف', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        onPressed: () => _showForm(context, null),
        icon: const Icon(Icons.add_box),
        label: const Text('إضافة صنف'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<AccountingCubit, AccountingState>(
              buildWhen: (prev, curr) =>
                  curr is ProductsLoaded ||
                  curr is AccountingLoading ||
                  curr is AccountingError,
              builder: (context, state) {
                if (state is AccountingLoading) return const Center(child: CircularProgressIndicator());
                if (state is AccountingError) return Center(child: Text(state.message));
                if (state is ProductsLoaded) {
                  final filtered = state.products
                      .where((p) => p.name.contains(_search) || p.code.contains(_search))
                      .toList();
                  if (filtered.isEmpty) return _buildEmpty();
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _ProductCard(
                      product: filtered[i],
                      onEdit: () => _showForm(context, filtered[i]),
                      onDelete: () => _confirmDelete(context, filtered[i]),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF6A1B9A),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'بحث باسم الصنف أو الكود...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text('لا يوجد منتجات بعد', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
      const SizedBox(height: 8),
      Text('اضغط + لإضافة صنف جديد', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
    ]),
  );

  void _showForm(BuildContext context, Product? product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductForm(
        product: product,
        onSave: (p) { context.read<AccountingCubit>().saveProduct(p); Navigator.pop(context); },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الصنف'),
        content: Text('هل تريد حذف "${product.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { context.read<AccountingCubit>().deleteProduct(product.id!); Navigator.pop(context); },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit, onDelete;
  const _ProductCard({required this.product, required this.onEdit, required this.onDelete});

  Color get _stockColor {
    if (product.quantity <= 0) return Colors.red;
    if (product.quantity <= 5) return Colors.orange;
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                child: const Icon(Icons.inventory_2, color: Color(0xFF6A1B9A), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('كود: ${product.code}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              ),
              PopupMenuButton<String>(
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('تعديل')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('حذف', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _infoChip(Icons.arrow_downward, 'شراء', '${product.buyPrice.toStringAsFixed(2)} ج.م', Colors.blue),
              const SizedBox(width: 8),
              _infoChip(Icons.arrow_upward, 'بيع', '${product.sellPrice.toStringAsFixed(2)} ج.م', Colors.teal),
              const SizedBox(width: 8),
              _infoChip(Icons.percent, 'خصم', '${product.discount.toStringAsFixed(1)}%', Colors.orange),
              const SizedBox(width: 8),
              _infoChip(Icons.inventory, 'رصيد', product.quantity.toStringAsFixed(1), _stockColor),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Icon(icon, size: 14, color: color),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ]),
      ),
    );
  }
}

class _ProductForm extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;
  const _ProductForm({this.product, required this.onSave});
  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  late final TextEditingController _code, _name, _buyPrice, _sellPrice;
  double _discount = 0;

  @override
  void initState() {
    super.initState();
    // توليد كود تلقائي إذا كان الصنف جديداً
    String initialCode = widget.product?.code ?? 'P-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    _code = TextEditingController(text: initialCode);
    _name = TextEditingController(text: widget.product?.name ?? '');
    _buyPrice = TextEditingController(text: widget.product?.buyPrice.toString() ?? '0');
    _sellPrice = TextEditingController(text: widget.product?.sellPrice.toString() ?? '0');
    _discount = widget.product?.discount ?? 0;
  }

  void _calculateDiscount() {
    double buy = double.tryParse(_buyPrice.text) ?? 0;
    double sell = double.tryParse(_sellPrice.text) ?? 0;
    setState(() {
      if (sell > 0) {
        _discount = ((sell - buy) / sell) * 100;
        if (_discount < 0) _discount = 0;
      } else {
        _discount = 0;
      }
    });
  }

  @override
  void dispose() {
    _code.dispose(); _name.dispose(); _buyPrice.dispose(); _sellPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product == null ? 'إضافة صنف جديد' : 'تعديل كارت الصنف',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _field(_code, 'كود الصنف', Icons.qr_code, readOnly: true)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _field(_name, 'اسم الصنف *', Icons.inventory_2)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _field(_buyPrice, 'سعر الشراء', Icons.arrow_downward, type: TextInputType.number, onChanged: (_) => _calculateDiscount())),
              const SizedBox(width: 10),
              Expanded(child: _field(_sellPrice, 'سعر البيع', Icons.arrow_upward, type: TextInputType.number, onChanged: (_) => _calculateDiscount())),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.percent, color: Colors.orange),
                  const SizedBox(width: 12),
                  const Text('نسبة الخصم التلقائية:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${_discount.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  if (_code.text.trim().isEmpty || _name.text.trim().isEmpty) return;
                  widget.onSave(Product(
                    id: widget.product?.id,
                    code: _code.text.trim(),
                    name: _name.text.trim(),
                    buyPrice: double.tryParse(_buyPrice.text) ?? 0,
                    sellPrice: double.tryParse(_sellPrice.text) ?? 0,
                    quantity: widget.product?.quantity ?? 0, // الحفاظ على الكمية السابقة
                    discount: _discount,
                  ));
                },
                child: const Text('حفظ الصنف', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text, bool readOnly = false, Function(String)? onChanged}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        fillColor: readOnly ? Colors.grey[100] : null,
        filled: readOnly,
      ),
    );
  }
}
