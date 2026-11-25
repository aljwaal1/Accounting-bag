import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_bag/professional_tools.dart';
void main(){
  test('IFRS 18 simplified subtotals',(){
    expect(ProfessionalMath.income(1000,400,200,50,-30,84),[600,400,450,420,336]);
  });
  test('negative equity balances',()=>expect(ProfessionalMath.balance(100,150,-50),0));
  test('break even and invalid contribution',(){
    expect(ProfessionalMath.breakEven(1000,20,10),100);
    expect(ProfessionalMath.breakEven(1000,10,10),isNull);
  });
  test('IAS 2 write down',(){
    expect(ProfessionalMath.nrvWriteDown(100,90,5,5),20);
    expect(ProfessionalMath.nrvWriteDown(100,150,5,5),0);
    expect(ProfessionalMath.nrvWriteDown(100,0,5,5),100);
  });
  test('inclusive VAT',()=>expect(ProfessionalMath.vatInclusive(120,20),closeTo(20,1e-9)));
  test('WACC after tax',()=>expect(ProfessionalMath.wacc(60,40,10,5,20),closeTo(7.6,1e-9)));
}
