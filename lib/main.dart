import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_acc/core/theme/app_theme.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_cubit.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';
import 'package:mobile_acc/features/accounting/data/repositories/repository_provider.dart';
import 'package:mobile_acc/features/accounting/presentation/widgets/account_list_tile.dart';
import 'package:mobile_acc/features/accounting/presentation/widgets/invoice_dialog.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final IAccountingRepository repository = getRepository();
  runApp(MobileAccApp(repository: repository));
}

class MobileAccApp extends StatelessWidget {
  final IAccountingRepository repository;

  const MobileAccApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountingCubit(repository)..loadAccounts(),
      child: MaterialApp(
        title: 'نظام الحسابات المحمول',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'),
        ],
        locale: const Locale('ar', 'SA'),
        home: const AccountingHomePage(),
      ),
    );
  }
}

class AccountingHomePage extends StatelessWidget {
  const AccountingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام حسابات الفواتير'),
        centerTitle: true,
      ),
      body: BlocBuilder<AccountingCubit, AccountingState>(
        builder: (context, state) {
          if (state is AccountingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AccountingLoaded) {
            return Column(
              children: [
                _buildSummaryHeader(state),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text('دليل الحسابات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.accounts.length,
                    itemBuilder: (context, index) {
                      final account = state.accounts[index];
                      return AccountListTile(
                        account: account,
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is AccountingError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('جاري بدء النظام...'));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: 'saleBtn',
                onPressed: () => _openInvoiceDialog(context, InvoiceType.sale),
                backgroundColor: AppTheme.primaryColor,
                label: const Text('فاتورة بيع جديدة'),
                icon: const Icon(Icons.add_shopping_cart),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: 'purchaseBtn',
                onPressed: () => _openInvoiceDialog(context, InvoiceType.purchase),
                backgroundColor: Colors.blueGrey,
                label: const Text('فاتورة شراء جديدة'),
                icon: const Icon(Icons.receipt_long),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(AccountingLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('إجمالي المبيعات', state.totalSales, Colors.greenAccent),
          Container(width: 1, height: 40, color: Colors.white24),
          _summaryItem('إجمالي المشتريات', state.totalPurchases, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)} ج.م',
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _openInvoiceDialog(BuildContext context, InvoiceType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => InvoiceDialog(
          type: type,
          onSave: (invoice) => context.read<AccountingCubit>().addInvoice(invoice),
        ),
      ),
    );
  }
}
