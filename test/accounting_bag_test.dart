import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_bag/main.dart';

void main() {
  test('formats numbers using western digits and thousands separators', () {
    expect(fmt(1234567.5), '1,234,567.50');
    expect(fmt(-1234.25), '-1,234.25');
  });

  testWidgets('renders Arabic sections and switches to English', (tester) async {
    await tester.pumpWidget(const AccountingBag());
    expect(find.text('الحقيبة المحاسبية'), findsOneWidget);
    expect(find.text('الحاسبات'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Accounting Bag'), findsOneWidget);
  });

  testWidgets('depreciation calculator returns the correct amount', (tester) async {
    await tester.pumpWidget(const AccountingBag());
    await tester.enterText(find.byType(TextField).at(0), '10000');
    await tester.enterText(find.byType(TextField).at(1), '1000');
    await tester.enterText(find.byType(TextField).at(2), '3');
    await tester.tap(find.text('احسب'));
    await tester.pump();
    expect(find.textContaining('3,000.00'), findsOneWidget);
  });
}
