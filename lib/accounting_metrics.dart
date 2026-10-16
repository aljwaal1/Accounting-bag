import 'package:flutter/material.dart';

class AccountingMetrics {
  static double straightLine(double cost,double residual,double life)=>(cost-residual)/life;
  static double declining(double bookValue,double rate)=>bookValue*rate/100;
  static double doubleDeclining(double bookValue,double life)=>bookValue*2/life;
  static double sumYears(double cost,double residual,double life,double year)=>(cost-residual)*(life-year+1)/(life*(life+1)/2);
  static double unitsOfProduction(double cost,double residual,double totalUnits,double usedUnits)=>(cost-residual)*usedUnits/totalUnits;
  static double currentRatio(double currentAssets,double currentLiabilities)=>currentAssets/currentLiabilities;
  static double quickRatio(double currentAssets,double inventory,double currentLiabilities)=>(currentAssets-inventory)/currentLiabilities;
  static double cashRatio(double cash,double currentLiabilities)=>cash/currentLiabilities;
  static double debtToEquity(double liabilities,double equity)=>liabilities/equity;
  static double debtRatio(double liabilities,double assets)=>liabilities/assets*100;
  static double grossMargin(double sales,double costOfSales)=>(sales-costOfSales)/sales*100;
  static double netMargin(double netProfit,double sales)=>netProfit/sales*100;
  static double roa(double netProfit,double assets)=>netProfit/assets*100;
  static double roe(double netProfit,double equity)=>netProfit/equity*100;
  static double assetTurnover(double sales,double assets)=>sales/assets;
  static double inventoryTurnover(double costOfSales,double averageInventory)=>costOfSales/averageInventory;
}

class AccountingMetricsScreen extends StatefulWidget {
  final bool en;
  final bool depreciation;
  const AccountingMetricsScreen({super.key,required this.en,required this.depreciation});
  @override State<AccountingMetricsScreen> createState()=>_AccountingMetricsState();
}
class _AccountingMetricsState extends State<AccountingMetricsScreen>{
  int mode=0;
  String? result;
  final ctrls=List.generate(4,(_)=>TextEditingController());
  String t(String ar,String en)=>widget.en?en:ar;
  @override void dispose(){for(final c in ctrls){c.dispose();}super.dispose();}
  @override Widget build(BuildContext context){
    final options=widget.depreciation?[
      [t('الإهلاك بالقسط الثابت','Straight-line depreciation'),t('تكلفة الأصل','Cost'),t('القيمة المتبقية','Residual value'),t('العمر بالسنوات','Useful life')],
      [t('الإهلاك بالقسط المتناقص','Declining balance'),t('القيمة الدفترية أول الفترة','Opening book value'),t('معدل الإهلاك %','Depreciation rate %')],
      [t('الإهلاك بالقسط المتناقص المضاعف','Double-declining balance'),t('القيمة الدفترية أول الفترة','Opening book value'),t('العمر بالسنوات','Useful life')],
      [t('الإهلاك بمجموع أرقام السنوات','Sum-of-years digits'),t('تكلفة الأصل','Cost'),t('القيمة المتبقية','Residual value'),t('العمر بالسنوات','Useful life'),t('رقم السنة','Year number')],
      [t('الإهلاك بوحدات الإنتاج','Units of production'),t('تكلفة الأصل','Cost'),t('القيمة المتبقية','Residual value'),t('إجمالي الوحدات المقدرة','Estimated total units'),t('وحدات الفترة','Period units')],
      [t('إطفاء الأصول غير الملموسة','Intangible asset amortization'),t('تكلفة الأصل','Cost'),t('القيمة المتبقية','Residual value'),t('العمر النافع','Useful life')]
    ]:[
      [t('نسبة التداول','Current ratio'),t('الأصول المتداولة','Current assets'),t('الالتزامات المتداولة','Current liabilities')],
      [t('نسبة السيولة السريعة','Quick ratio'),t('الأصول المتداولة','Current assets'),t('المخزون','Inventory'),t('الالتزامات المتداولة','Current liabilities')],
      [t('نسبة النقدية','Cash ratio'),t('النقدية وما يعادلها','Cash and equivalents'),t('الالتزامات المتداولة','Current liabilities')],
      [t('الديون إلى حقوق الملكية','Debt to equity'),t('إجمالي الالتزامات','Total liabilities'),t('حقوق الملكية','Equity')],
      [t('نسبة المديونية','Debt ratio'),t('إجمالي الالتزامات','Total liabilities'),t('إجمالي الأصول','Total assets')],
      [t('هامش مجمل الربح','Gross profit margin'),t('صافي المبيعات','Net sales'),t('تكلفة المبيعات','Cost of sales')],
      [t('هامش صافي الربح','Net profit margin'),t('صافي الربح','Net income'),t('صافي المبيعات','Net sales')],
      [t('العائد على الأصول','Return on assets'),t('صافي الربح','Net income'),t('متوسط الأصول','Average assets')],
      [t('العائد على حقوق الملكية','Return on equity'),t('صافي الربح','Net income'),t('متوسط حقوق الملكية','Average equity')],
      [t('دوران الأصول','Asset turnover'),t('صافي المبيعات','Net sales'),t('متوسط الأصول','Average assets')],
      [t('دوران المخزون','Inventory turnover'),t('تكلفة المبيعات','Cost of sales'),t('متوسط المخزون','Average inventory')]
    ];
    void compute(){
      final values=<double>[];
      for(var i=1;i<options[mode].length;i++){
        final v=double.tryParse(ctrls[i-1].text.trim().replaceAll(',',''));
        if(v==null || !v.isFinite){setState(()=>result=t('أدخل أرقامًا صحيحة','Enter valid numbers'));return;}
        values.add(v);
      }
      final a=values[0],b=values[1],c=values.length>2?values[2]:0,d=values.length>3?values[3]:0;
      double? value;
      if(widget.depreciation){
        switch(mode){
          case 0:case 5: if(a>=b && b>=0 && c>0)value=AccountingMetrics.straightLine(a,b,c);break;
          case 1:if(a>=0 && b>=0 && b<=100)value=AccountingMetrics.declining(a,b);break;
          case 2:if(a>=0 && b>=2)value=AccountingMetrics.doubleDeclining(a,b);break;
          case 3:if(a>=b && b>=0 && c>0 && c==c.roundToDouble() && d>=1 && d<=c && d==d.roundToDouble())value=AccountingMetrics.sumYears(a,b,c,d);break;
          case 4:if(a>=b && b>=0 && c>0 && d>=0 && d<=c)value=AccountingMetrics.unitsOfProduction(a,b,c,d);break;
        }
      }else{
        switch(mode){
          case 0:if(b>0)value=AccountingMetrics.currentRatio(a,b);break;
          case 1:if(c>0)value=AccountingMetrics.quickRatio(a,b,c);break;
          case 2:if(b>0)value=AccountingMetrics.cashRatio(a,b);break;
          case 3:if(b>0)value=AccountingMetrics.debtToEquity(a,b);break;
          case 4:if(b>0)value=AccountingMetrics.debtRatio(a,b);break;
          case 5:if(a>0)value=AccountingMetrics.grossMargin(a,b);break;
          case 6:if(b>0)value=AccountingMetrics.netMargin(a,b);break;
          case 7:if(b>0)value=AccountingMetrics.roa(a,b);break;
          case 8:if(b>0)value=AccountingMetrics.roe(a,b);break;
          case 9:if(b>0)value=AccountingMetrics.assetTurnover(a,b);break;
          case 10:if(b>0)value=AccountingMetrics.inventoryTurnover(a,b);break;
        }
      }
      final percentage=!widget.depreciation && [4,5,6,7,8].contains(mode);
      setState(()=>result=value==null || !value.isFinite?t('تحقق من المدخلات والمقام','Check inputs and denominator'):'${t('النتيجة','Result')}: ${value.toStringAsFixed(2)}${percentage?'%':''}');
    }
    return ListView(padding:const EdgeInsets.all(12),children:[
      Text(widget.depreciation?t('الاستهلاك والإطفاء','Depreciation & amortization'):t('النسب المالية','Financial ratios'),style:Theme.of(context).textTheme.titleLarge),
      const SizedBox(height:12),
      DropdownButtonFormField<int>(initialValue:mode,isExpanded:true,
        items:List.generate(options.length,(i)=>DropdownMenuItem(value:i,child:Text(options[i][0],overflow:TextOverflow.ellipsis))),
        onChanged:(v)=>setState((){mode=v??0;result=null;for(final c in ctrls){c.clear();}})),
      const SizedBox(height:12),
      for(var i=1;i<options[mode].length;i++)Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:ctrls[i-1],
        keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),
        decoration:InputDecoration(labelText:options[mode][i],border:const OutlineInputBorder()))),
      FilledButton(onPressed:compute,child:Text(t('احسب','Calculate'))),
      if(result!=null)Padding(padding:const EdgeInsets.all(12),child:SelectableText(result!,style:Theme.of(context).textTheme.titleMedium)),
      Text(widget.depreciation?t('نتائج الإهلاك تقديرية للفترة. في الطرق المتناقصة يجب مراعاة القيمة المتبقية عند إعداد جدول الإهلاك الكامل.','Period depreciation is indicative. Declining methods require residual-value limits in full schedules.'):t('النسب تعتمد على القيم المدخلة؛ استخدم متوسط الأرصدة في نسب العائد والدوران.','Ratios use entered values; use average balances for return and turnover ratios.'))
    ]);
  }
}
