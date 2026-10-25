import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_5/main.dart';

void main() {
  testWidgets('Aplikasi Expense Tracker dapat dibangun', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExpenseTrackerApp(initialRoute: '/'));

    expect(find.byType(ExpenseTrackerApp), findsOneWidget);
  });
}