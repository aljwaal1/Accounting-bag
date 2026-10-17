import 'dart:math' as math;

/// Annual, end-of-year cash flows. Initial investment is a negative cash flow at t=0.
class FeasibilityAnalysis {
  static double npv(double rate, List<double> cashFlows) {
    if(!rate.isFinite || rate<=-1 || cashFlows.isEmpty || cashFlows.any((x)=>!x.isFinite)) {
      throw ArgumentError('Invalid discount rate or cash flows');
    }
    var total=0.0;
    for(var i=0;i<cashFlows.length;i++){
      total+=cashFlows[i]/math.pow(1+rate,i);
    }
    return total;
  }

  /// Finds a root using a bracketed bisection method; null if no bracket is found.
  /// Multiple IRRs are possible for non-conventional cash flows; only one root is returned.
  static double? irr(List<double> flows) {
    if(flows.length<2 || flows.any((x)=>!x.isFinite) ||
       !flows.any((x)=>x<0) || !flows.any((x)=>x>0))return null;
    // Non-conventional cash flows can have multiple IRRs; avoid misleading single-root output.
    var signChanges=0;
    var previousSign=0;
    for(final value in flows){
      final sign=value>0?1:(value<0?-1:0);
      if(sign==0)continue;
      if(previousSign!=0 && previousSign!=sign)signChanges++;
      previousSign=sign;
    }
    if(signChanges!=1)return null;
    var lo=-0.9999;
    var hi=1.0;
    var left=npv(lo,flows);
    var right=npv(hi,flows);
    while(left*right>0 && hi<1000000){
      hi=hi*2+1;
      right=npv(hi,flows);
    }
    if(left*right>0)return null;
    for(var i=0;i<180;i++){
      final mid=(lo+hi)/2;
      final value=npv(mid,flows);
      if(value.abs()<1e-9 || (hi-lo)<1e-12)return mid;
      if(left*value<=0){hi=mid;}else{lo=mid;left=value;}
    }
    return (lo+hi)/2;
  }

  static double? discountedPayback(double rate,List<double> flows){
    if(!rate.isFinite || rate<=-1 || flows.length<2 || flows.any((x)=>!x.isFinite) || flows.first>=0)return null;
    var cumulative=flows.first;
    for(var i=1;i<flows.length;i++){
      final discounted=flows[i]/math.pow(1+rate,i);
      if(discounted>0 && cumulative+discounted>=0){
        return (i-1)+(-cumulative)/discounted;
      }
      cumulative+=discounted;
    }
    return null;
  }

  static List<double> projection({
    required double investment,
    required double annualRevenue,
    required double annualOperatingCosts,
    required int years,
    required double revenueGrowth,
    required double costGrowth,
    double terminalRecovery=0,
  }){
    if(years<1 || years>30 || investment<0 || annualRevenue<0 ||
      annualOperatingCosts<0 || terminalRecovery<0 || revenueGrowth<=-1 ||
      costGrowth<=-1 || !investment.isFinite || !annualRevenue.isFinite ||
      !annualOperatingCosts.isFinite || !terminalRecovery.isFinite ||
      !revenueGrowth.isFinite || !costGrowth.isFinite)throw ArgumentError('Invalid forecast inputs');
    final flows=<double>[-investment];
    for(var year=1;year<=years;year++){
      final income=annualRevenue*math.pow(1+revenueGrowth,year-1);
      final costs=annualOperatingCosts*math.pow(1+costGrowth,year-1);
      flows.add(income-costs+(year==years?terminalRecovery:0));
    }
    return flows;
  }
}
