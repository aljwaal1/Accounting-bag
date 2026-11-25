import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_bag/number_input.dart';
void main(){
  test('Arabic and Persian digits with grouping',(){
    expect(parseAccountingNumber('١٬٢٣٤٫٥٠'),1234.5);
    expect(parseAccountingNumber('۱۲۳٫۵'),123.5);
    expect(parseAccountingNumber('−١٢'),-12);
    expect(parseAccountingNumber('1,234.50'),1234.5);
  });
  test('reject ambiguous grouping and nonfinite values',(){
    for(final s in ['1,5','12,34','NaN','Infinity','1e999','']) {
      expect(parseAccountingNumber(s),isNull,reason:s);
    }
  });
}
