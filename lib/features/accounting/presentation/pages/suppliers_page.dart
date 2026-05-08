import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_cubit.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_state.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});
  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<AccountingCubit>().loadSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الموردون', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        onPressed: () => _showForm(context, null),
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة مورد'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<AccountingCubit, AccountingState>(
              buildWhen: (prev, curr) =>
                  curr is SuppliersLoaded ||
                  curr is AccountingLoading ||
                  curr is AccountingError,
              builder: (context, state) {
                if (state is AccountingLoading) return const Center(child: CircularProgressIndicator());
                if (state is AccountingError) return Center(child: Text(state.message));
                if (state is SuppliersLoaded) {
                  final filtered = state.suppliers
                      .where((s) => s.name.contains(_search) || s.phone.contains(_search))
                      .toList();
                  if (filtered.isEmpty) return _buildEmpty();
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _SupplierCard(
                      supplier: filtered[i],
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
      color: const Color(0xFF1565C0),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'بحث باسم المورد أو الهاتف...',
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
      Icon(Icons.store_outlined, size: 80, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text('لا يوجد موردون بعد', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
      const SizedBox(height: 8),
      Text('اضغط + لإضافة مورد جديد', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
    ]),
  );

  void _showForm(BuildContext context, Supplier? supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SupplierForm(
        supplier: supplier,
        onSave: (s) { context.read<AccountingCubit>().saveSupplier(s); Navigator.pop(context); },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المورد'),
        content: Text('هل تريد حذف "${supplier.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { context.read<AccountingCubit>().deleteSupplier(supplier.id!); Navigator.pop(context); },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onEdit, onDelete;
  const _SupplierCard({required this.supplier, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
          child: Text(supplier.name.isNotEmpty ? supplier.name[0] : '؟',
              style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
        ),
        title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: supplier.phone.isNotEmpty ? Text(supplier.phone, style: const TextStyle(fontSize: 12)) : null,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('${supplier.balance.toStringAsFixed(2)} ج.م',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1565C0))),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('تعديل')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('حذف', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ]),
      ),
    );
  }
}

class _SupplierForm extends StatefulWidget {
  final Supplier? supplier;
  final Function(Supplier) onSave;
  const _SupplierForm({this.supplier, required this.onSave});
  @override
  State<_SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<_SupplierForm> {
  late final TextEditingController _name, _phone, _email, _address, _balance;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.supplier?.name ?? '');
    _phone = TextEditingController(text: widget.supplier?.phone ?? '');
    _email = TextEditingController(text: widget.supplier?.email ?? '');
    _address = TextEditingController(text: widget.supplier?.address ?? '');
    _balance = TextEditingController(text: widget.supplier?.balance.toString() ?? '0');
  }

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _email.dispose(); _address.dispose(); _balance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.supplier == null ? 'إضافة مورد جديد' : 'تعديل بيانات المورد',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _field(_name, 'اسم المورد *', Icons.store),
          const SizedBox(height: 10),
          _field(_phone, 'رقم الهاتف', Icons.phone, type: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_email, 'البريد الإلكتروني', Icons.email, type: TextInputType.emailAddress),
          const SizedBox(height: 10),
          _field(_address, 'العنوان', Icons.location_on),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                if (_name.text.trim().isEmpty) return;
                widget.onSave(Supplier(id: widget.supplier?.id, name: _name.text.trim(), phone: _phone.text.trim(), email: _email.text.trim(), address: _address.text.trim(), balance: double.tryParse(_balance.text) ?? 0));
              },
              child: const Text('حفظ', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(controller: ctrl, keyboardType: type, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true));
  }
}
