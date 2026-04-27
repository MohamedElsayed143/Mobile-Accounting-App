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
  });
}
