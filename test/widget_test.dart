import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_acc/features/accounting/presentation/bloc/accounting_cubit.dart';
import 'package:mobile_acc/features/accounting/presentation/pages/login_page.dart';
import 'package:mobile_acc/features/accounting/data/repositories/sql_accounting_repository.dart';
import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/data/datasources/database_helper.dart';

class MockSqlRepo implements SqlAccountingRepository {
  @override
  final dbHelper = DatabaseHelper();

  @override
  Future<List<Account>> getAccounts() async => [];
  @override
  Future<void> addAccount(Account account) async {}
  @override
  Future<void> addInvoice(Invoice invoice) async {}
  @override
  Future<void> saveInvoice(Invoice invoice) async {}
}

void main() {
  testWidgets('Core App Smoke Test', (WidgetTester tester) async {
    final mockRepo = MockSqlRepo();
    
    await tester.pumpWidget(
      BlocProvider(
        create: (context) => AccountingCubit(mockRepo)..loadAccounts(),
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify login page is shown
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
