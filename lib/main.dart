import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_cubit.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_state.dart';
import 'package:mobile_acc/features/accounting/data/repositories/firestore_accounting_repository.dart';
import 'package:mobile_acc/features/accounting/presentation/pages/login_page.dart';
import 'package:mobile_acc/features/accounting/presentation/pages/invoices_page.dart';
import 'package:mobile_acc/features/accounting/presentation/pages/customers_page.dart';
import 'package:mobile_acc/features/accounting/presentation/pages/suppliers_page.dart';
import 'package:mobile_acc/features/accounting/presentation/pages/products_page.dart';
import 'package:mobile_acc/features/accounting/presentation/widgets/summary_charts_widget.dart';
import 'package:mobile_acc/features/accounting/presentation/pages/settings_page.dart';
import 'package:mobile_acc/core/settings/settings_cubit.dart';
import 'package:mobile_acc/core/settings/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final FirestoreAccountingRepository repository = FirestoreAccountingRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AccountingCubit(repository: repository)),
        BlocProvider(create: (context) => SettingsCubit()),
      ],
      child: const MobileAccApp(),
    ),
  );
}

class MobileAccApp extends StatelessWidget {
  const MobileAccApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'نظام المحاسبة الاحترافي',
          themeMode: state.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, primary: const Color(0xFF00695C)),
            scaffoldBackgroundColor: const Color(0xFFF4F7FC),
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, primary: const Color(0xFF00695C), brightness: Brightness.dark),
            useMaterial3: true,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
          locale: state.locale,
          home: const CustomSplashScreen(),
        );
      },
    );
  }
}

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        final Widget nextScreen = user != null ? const MainAccountingPage() : const LoginPage();

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00695C),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'نظام المحاسبة الذكي',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class MainAccountingPage extends StatefulWidget {
  const MainAccountingPage({super.key});

  @override
  State<MainAccountingPage> createState() => _MainAccountingPageState();
}

class _MainAccountingPageState extends State<MainAccountingPage> {
  @override
  void initState() {
    super.initState();
    // ✅ مرة واحدة فقط عند بداية الشاشة وليس عند كل إعادة رسم
    context.read<AccountingCubit>().loadAccounts();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم المالي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AccountingCubit, AccountingState>(
        // ✅ يتجاهل أي حالة من صفحات أخرى (مثل CustomersLoaded, InvoicesLoaded)
        buildWhen: (prev, curr) =>
            curr is AccountingLoading ||
            curr is AccountingLoaded ||
            curr is AccountingError,
        builder: (context, state) {
          if (state is AccountingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AccountingLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderStats(state),
                  _buildChartsSection(state),
                  _buildQuickActions(context),
                  _buildManagementSection(context, state),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text("دليل الحسابات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.accounts.length,
                    itemBuilder: (context, index) => _buildEnhancedAccountCard(context, state.accounts[index]),
                  ),
                ],
              ),
            );
          }

          if (state is AccountingError) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                Text(state.message),
                ElevatedButton(
                  onPressed: () => context.read<AccountingCubit>().loadAccounts(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildChartsSection(AccountingLoaded state) {
    return Container(
      height: 350,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: SummaryChartsWidget(sales: state.totalSales, purchases: state.totalPurchases),
    );
  }

  Widget _buildHeaderStats(AccountingLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _statCard("المبيعات", state.totalSales, Colors.green, Icons.trending_up),
          const SizedBox(width: 12),
          _statCard("المشتريات", state.totalPurchases, Colors.redAccent, Icons.trending_down),
        ],
      ),
    );
  }

  Widget _statCard(String title, double value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text("${value.toStringAsFixed(2)} ج.م", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InvoicesPage()),
        ).then((_) {
          // ✅ إعادة تحميل الداشبورد عند العودة
          if (context.mounted) context.read<AccountingCubit>().loadAccounts();
        }),
        icon: const Icon(Icons.receipt_long),
        label: const Text("سجل الفواتير"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.withValues(alpha: 0.1),
          foregroundColor: Colors.teal,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context, AccountingLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _mCard(context, "العملاء", Icons.people, const Color(0xFF00897B), const CustomersPage(), state.customerCount),
          const SizedBox(width: 12),
          _mCard(context, "الموردين", Icons.store, const Color(0xFF1565C0), const SuppliersPage(), state.supplierCount),
          const SizedBox(width: 12),
          _mCard(context, "الأصناف", Icons.inventory, const Color(0xFF6A1B9A), const ProductsPage(), state.productCount),
        ],
      ),
    );
  }

  Widget _mCard(BuildContext context, String t, IconData i, Color c, Widget p, int count) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => p),
        ).then((_) {
          // ✅ إعادة تحميل الداشبورد عند العودة من أي صفحة فرعية
          if (context.mounted) context.read<AccountingCubit>().loadAccounts();
        }),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Icon(i, color: c),
            Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text("$count", style: TextStyle(color: c.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _buildEnhancedAccountCard(BuildContext context, dynamic account) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFF00695C).withValues(alpha: 0.1), child: const Icon(Icons.wallet, color: Color(0xFF00695C), size: 20)),
        title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: Text("${account.balance} ج.م", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
