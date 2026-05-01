import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_cubit.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_state.dart';
import 'package:mobile_acc/features/accounting/data/repositories/sql_accounting_repository.dart';
import 'package:mobile_acc/features/accounting/presentation/widgets/summary_charts_widget.dart';
import 'package:mobile_acc/features/accounting/presentation/pages/login_page.dart';
import 'package:mobile_acc/features/accounting/presentation/widgets/invoice_dialog.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final SqlAccountingRepository repository = SqlAccountingRepository();

  runApp(
    BlocProvider(
      create: (context) => AccountingCubit(repository)..loadAccounts(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'نظام المحاسبة',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF4F7FC),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'),
        ],
        locale: const Locale('ar', 'SA'),
        home: const LoginPage(),
      ),
    ),
  );
}

class MainAccountingPage extends StatelessWidget {
  const MainAccountingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('لوحة التحكم المالي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {})],
      ),
      body: BlocBuilder<AccountingCubit, AccountingState>(
        builder: (context, state) {
          if (state is AccountingLoading) return const Center(child: CircularProgressIndicator());
          if (state is AccountingLoaded) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderStats(state),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("تحليل النشاط المالي", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _buildChartsSection(state),
                  _buildQuickActions(context, state),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("دليل الحسابات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.accounts.length,
                    itemBuilder: (context, index) {
                      final account = state.accounts[index];
                      return _buildEnhancedAccountCard(context, account);
                    },
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("حدث خطأ في تحميل البيانات"));
        },
      ),
    );
  }

  Widget _buildChartsSection(AccountingLoaded state) {
    return Container(
      height: 400,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: SummaryChartsWidget(
        sales: state.totalSales,
        purchases: state.totalPurchases,
      ),
    );
  }

  Widget _buildHeaderStats(AccountingLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _statCard("إجمالي المبيعات", "${state.totalSales}", Colors.green, Icons.trending_up),
          const SizedBox(width: 12),
          _statCard("إجمالي المشتريات", "${state.totalPurchases}", Colors.redAccent, Icons.trending_down),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text("$value ج.م", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AccountingLoaded state) {
    final int? firstAccountId = state.accounts.isNotEmpty ? state.accounts.first.id : null;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _actionCard(context, "فاتورة بيع", Icons.add_shopping_cart, Colors.green, firstAccountId),
          const SizedBox(width: 12),
          _actionCard(context, "فاتورة شراء", Icons.inventory, Colors.blueGrey, firstAccountId),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, String title, IconData icon, Color color, int? accountId) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (accountId == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceDialog(
                accountId: accountId,
                type: title.contains("بيع") ? InvoiceType.sale : InvoiceType.purchase,
                onSave: (invoice) => context.read<AccountingCubit>().addInvoice(invoice),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAccountCard(BuildContext context, dynamic account) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () => _showLastTransaction(context, account),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF00695C).withValues(alpha: 0.1),
          child: const Icon(Icons.wallet, color: Color(0xFF00695C), size: 20),
        ),
        title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("كود: ${account.code}", style: const TextStyle(fontSize: 12)),
        trailing: Text("${account.balance} ج.م", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showLastTransaction(BuildContext context, dynamic account) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
          Text("آخر عملية: ${account.name}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    ),
    ),
    );
  }
}

