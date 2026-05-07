import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_cubit.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_state.dart';
import 'package:mobile_acc/features/accounting/presentation/widgets/invoice_dialog.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadForTab(_tabController.index);
      }
    });
    // تحميل فواتير البيع أول ما الصفحة تفتح
    context.read<AccountingCubit>().loadInvoices(type: 'sale');
  }

  void _loadForTab(int index) {
    final type = index == 0 ? 'sale' : 'purchase';
    context.read<AccountingCubit>().loadInvoices(type: type);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openNewInvoiceDialog(InvoiceType type) async {
    final cubit = context.read<AccountingCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final accounts = await cubit.repository.getAccounts();
    if (!mounted) return;

    if (accounts.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('لا يوجد حسابات، أضف حساباً أولاً')),
      );
      return;
    }

    await nav.push(
      MaterialPageRoute(
        builder: (context) => InvoiceDialog(
          accountId: accounts.first.id!,
          type: type,
          onSave: (invoice) async {
            await cubit.addInvoice(invoice);
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                    '✅ تم حفظ ${type == InvoiceType.sale ? 'فاتورة البيع' : 'فاتورة الشراء'} بنجاح'),
                backgroundColor: const Color(0xFF00695C),
              ),
            );
          },
        ),
      ),
    );

    // إعادة تحميل الفواتير بعد الرجوع
    _loadForTab(_tabController.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الفواتير',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'فواتير البيع'),
            Tab(icon: Icon(Icons.trending_down), text: 'فواتير الشراء'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        onPressed: () {
          final type = _tabController.index == 0
              ? InvoiceType.sale
              : InvoiceType.purchase;
          _openNewInvoiceDialog(type);
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'فاتورة بيع' : 'فاتورة شراء'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InvoiceListView(type: InvoiceType.sale),
          _InvoiceListView(type: InvoiceType.purchase),
        ],
      ),
    );
  }
}

class _InvoiceListView extends StatelessWidget {
  final InvoiceType type;
  const _InvoiceListView({required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountingCubit, AccountingState>(
      builder: (context, state) {
        if (state is AccountingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AccountingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 12),
                Text(state.message, textAlign: TextAlign.center),
              ],
            ),
          );
        }

        if (state is InvoicesLoaded) {
          final invoices =
              state.invoices.where((inv) => inv.type == type).toList();

          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type == InvoiceType.sale
                        ? Icons.receipt_long
                        : Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    type == InvoiceType.sale
                        ? 'لا توجد فواتير بيع بعد'
                        : 'لا توجد فواتير شراء بعد',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط + لإضافة فاتورة جديدة',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            );
          }

          // حساب الإجمالي
          final total =
              invoices.fold(0.0, (sum, inv) => sum + inv.totalAmount);

          return Column(
            children: [
              // شريط الإجمالي
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: type == InvoiceType.sale
                    ? Colors.teal.withValues(alpha: 0.1)
                    : Colors.blueGrey.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${invoices.length} فاتورة',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'الإجمالي: ${total.toStringAsFixed(2)} ج.م',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: type == InvoiceType.sale
                            ? Colors.teal[700]
                            : Colors.blueGrey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    return _InvoiceCard(
                        invoice: invoices[index], type: type);
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final InvoiceType type;

  const _InvoiceCard({required this.invoice, required this.type});

  @override
  Widget build(BuildContext context) {
    final isSale = type == InvoiceType.sale;
    final color = isSale ? Colors.teal : Colors.blueGrey;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            isSale ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          invoice.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          'رقم: ${invoice.invoiceNumber.length > 8 ? invoice.invoiceNumber.substring(invoice.invoiceNumber.length - 8) : invoice.invoiceNumber}  •  ${invoice.date}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        trailing: Text(
          '${invoice.totalAmount.toStringAsFixed(2)} ج.م',
          style: TextStyle(
            color: isSale ? Colors.teal[700] : Colors.blueGrey[700],
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: invoice.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(item.description,
                              style: const TextStyle(fontSize: 13))),
                      Text(
                        '${item.quantity.toStringAsFixed(0)} × ${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.total.toStringAsFixed(2)} ج.م',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: color[700]),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
