<<<<<<< HEAD
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
=======
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_acc/main.dart';
import 'package:mobile_acc/features/accounting/data/repositories/mock_accounting_repository.dart';

void main() {
  testWidgets('Core App Smoke Test', (WidgetTester tester) async {
    // Build our app with a Mock Repository and trigger a frame.
    await tester.pumpWidget(MobileAccApp(repository: MockAccountingRepository()));

    // Wait for the mock data delay and initial animation
    await tester.pumpAndSettle();

    // Verify that our initial load happens (Search for Arabic text)
    // Verify that our initial load happens (Search for Arabic text)
    expect(find.text('نظام حسابات الفواتير'), findsOneWidget);
    
    // Check that some mock accounts are displayed
    expect(find.text('الصندوق الرئيسي'), findsOneWidget);
    expect(find.text('البنك الأهلي'), findsOneWidget);
    
    // Verify the summary header is rendered
    expect(find.text('إجمالي المبيعات'), findsOneWidget);
    expect(find.text('إجمالي المشتريات'), findsOneWidget);

    // Verify the new invoice buttons exist.
    expect(find.text('فاتورة بيع جديدة'), findsOneWidget);
    expect(find.text('فاتورة شراء جديدة'), findsOneWidget);
>>>>>>> ed920add641ad572834a8497a7acf871376b41b6
  });
}
