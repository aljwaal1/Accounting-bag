import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accounting_bag/smart_tools.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<void> open(WidgetTester tester, String mode) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SmartTools(en: true))));
    await tester.pumpAndSettle();
    await tester.tap(find.text(mode));
    await tester.pumpAndSettle();
  }
  Future<void> enter(WidgetTester tester, List<String> values) async {
    for (var i=0;i<values.length;i++) {
      final field=find.byType(TextField).at(i);
      await tester.ensureVisible(field);
      await tester.enterText(field,values[i]);
      await tester.pump();
    }
  }
  testWidgets('pricing uses margin rather than markup', (tester) async {
    await open(tester,'Pricing');
    await enter(tester,['80','20','10']);
    expect(find.textContaining('Final price: 110.00'),findsOneWidget);
  });
  testWidgets('negative equity reconciles correctly', (tester) async {
    await open(tester,'Financial check');
    await enter(tester,['100','150','-50']);
    expect(find.textContaining('Accounting equation difference: 0.00'),findsOneWidget);
  });
  testWidgets('excess expense accrual reverses debit and credit', (tester) async {
    await open(tester,'Accrual adjustment');
    await enter(tester,['8000','10000']);
    expect(find.textContaining('Debit: Accrued expenses — 2000.00'),findsOneWidget);
  });
  testWidgets('journal search filters accounts', (tester) async {
    await open(tester,'Smart entries');
    await tester.enterText(find.byType(TextField).first,'xyz-no-match');
    await tester.pump();
    expect(find.text('No matching entries'),findsOneWidget);
  });
}
