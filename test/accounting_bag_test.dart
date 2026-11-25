import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_bag/main.dart';

void main() {
  setUp(()=>SharedPreferences.setMockInitialValues({}));
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
    final fields=find.descendant(of:find.byType(CalculatorScreen),matching:find.byType(TextField));
    await tester.enterText(fields.at(0), '10000');
    await tester.enterText(fields.at(1), '1000');
    await tester.enterText(fields.at(2), '3');
    await tester.ensureVisible(find.text('احسب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('احسب'));

    await tester.pump();
    expect(find.textContaining('3,000.00'), findsOneWidget);
  });
  testWidgets('restores dark mode and favorites', (tester) async {
    SharedPreferences.setMockInitialValues({'bag_dark':true,'bag_english':true,'bag_favorites':['0']});
    await tester.pumpWidget(const AccountingBag());
    await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,ThemeMode.dark);
    await tester.tap(find.byTooltip('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Calculators'),findsOneWidget);
    expect(find.text('Interest & Finance'),findsNothing);
  });
  testWidgets('compact viewport remains scrollable without overflow', (tester) async {
    tester.view.physicalSize=const Size(320,480);
    tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const AccountingBag());
    await tester.pumpAndSettle();
    expect(tester.takeException(),isNull);
    expect(find.text('الحقيبة المحاسبية'),findsOneWidget);
  });
}
