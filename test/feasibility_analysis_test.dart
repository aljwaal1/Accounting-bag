import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_bag/feasibility_analysis.dart';

void main(){
  test('NPV for initial outlay and two annual inflows',(){
    expect(FeasibilityAnalysis.npv(0.10,[-100,60,60]),closeTo(4.1322314,0.0001));
  });
  test('IRR for simple one-year project',(){
    expect(FeasibilityAnalysis.irr([-100,110]),closeTo(0.10,0.000001));
  });
  test('IRR unavailable without a sign change',(){
    expect(FeasibilityAnalysis.irr([100,110]),isNull);
  });
  test('zero growth projection and terminal recovery',(){
    expect(FeasibilityAnalysis.projection(investment:100,annualRevenue:80,
      annualOperatingCosts:30,years:2,revenueGrowth:0,costGrowth:0,terminalRecovery:10),
      [-100,50,60]);
  });
  test('discounted payback within second year',(){
    expect(FeasibilityAnalysis.discountedPayback(0,[-100,60,60]),closeTo(1.6666667,0.00001));
  });
  test('reject invalid discount rate',(){
    expect(()=>FeasibilityAnalysis.npv(-1,[-100,110]),throwsArgumentError);
  });
}
