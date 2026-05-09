import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_cubit.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_state.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});
  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<AccountingCubit>().loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('customers'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        onPressed: () => _showForm(context, null),
        icon: const Icon(Icons.person_add),
        label: Text('add_customer'.tr()),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<AccountingCubit, AccountingState>(
        buildWhen: (prev, curr) => curr is CustomersLoaded || curr is AccountingLoading || curr is AccountingError,
        builder: (context, state) {
                if (state is AccountingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AccountingError) {
                  return Center(child: Text(state.message));
                }
                if (state is CustomersLoaded) {
                  final filtered = state.customers
                      .where((c) =>
                          c.name.contains(_search) ||
                          c.phone.contains(_search))
                      .toList();
                  if (filtered.isEmpty) {
                    return _buildEmpty();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _CustomerCard(
                      customer: filtered[i],
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
      color: const Color(0xFF00897B),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'search_by_customer_name_or_phone'.tr(),
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('no_customers_yet'.tr(),
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 8),
          Text('press_plus_to_add_a_new_customer'.tr(),
              style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, Customer? customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomerForm(
        customer: customer,
        onSave: (c) {
          context.read<AccountingCubit>().saveCustomer(c);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_customer'.tr()),
        content: Text('هل تريد حذف "${customer.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AccountingCubit>().deleteCustomer(customer.id!);
              Navigator.pop(context);
            },
            child: Text('delete'.tr(), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _CustomerCard({required this.customer, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF00897B).withValues(alpha: 0.1),
          child: Text(
            customer.name.isNotEmpty ? customer.name[0] : 'key_84'.tr(),
            style: const TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone.isNotEmpty) Text(customer.phone, style: const TextStyle(fontSize: 12)),
            if (customer.address.isNotEmpty)
              Text(customer.address, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${customer.balance.toStringAsFixed(2)} ج.م',
                style: TextStyle(
                    color: customer.balance >= 0 ? Colors.teal[700] : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('edit'.tr())])),
                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('delete'.tr(), style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerForm extends StatefulWidget {
  final Customer? customer;
  final Function(Customer) onSave;
  const _CustomerForm({this.customer, required this.onSave});

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  late final TextEditingController _name, _phone, _email, _address, _balance;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.customer?.name ?? '');
    _phone = TextEditingController(text: widget.customer?.phone ?? '');
    _email = TextEditingController(text: widget.customer?.email ?? '');
    _address = TextEditingController(text: widget.customer?.address ?? '');
    _balance = TextEditingController(text: widget.customer?.balance.toString() ?? '0');
  }

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _email.dispose();
    _address.dispose(); _balance.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.customer == null ? 'add_new_customer'.tr() : 'edit_customer_details'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _field(_name, 'customer_name'.tr(), Icons.person),
          const SizedBox(height: 10),
          _field(_phone, 'phone_number'.tr(), Icons.phone, type: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_email, 'email'.tr(), Icons.email, type: TextInputType.emailAddress),
          const SizedBox(height: 10),
          _field(_address, 'address'.tr(), Icons.location_on),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_name.text.trim().isEmpty) return;
                widget.onSave(Customer(
                  id: widget.customer?.id,
                  name: _name.text.trim(),
                  phone: _phone.text.trim(),
                  email: _email.text.trim(),
                  address: _address.text.trim(),
                  balance: double.tryParse(_balance.text) ?? 0,
                ));
              },
              child: Text('save'.tr(), style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
    );
  }
}

