import 'package:flutter/material.dart';
import 'accounting_metrics.dart';

class ComprehensiveRatiosScreen extends StatefulWidget {
  final bool en;
  const ComprehensiveRatiosScreen({super.key,required this.en});
  @override State<ComprehensiveRatiosScreen> createState()=>_ComprehensiveRatiosState();
}
class _ComprehensiveRatiosState extends State<ComprehensiveRatiosScreen> {
  final fields=List.generate(13,(_)=>TextEditingController());
  bool calculated=false;
  String t(String ar,String en)=>widget.en?en:ar;
  @override void dispose(){for(final f in fields){f.dispose();}super.dispose();}
  @override Widget build(BuildContext context){
    final labels=[
      t('الأصول المتداولة','Current assets'),t('المخزون','Inventory'),
      t('النقدية وما يعادلها','Cash and equivalents'),t('الالتزامات المتداولة','Current liabilities'),
      t('إجمالي الالتزامات','Total liabilities'),t('إجمالي الأصول نهاية الفترة','Ending total assets'),
      t('حقوق الملكية نهاية الفترة','Ending equity'),t('صافي المبيعات','Net sales'),
      t('تكلفة المبيعات','Cost of sales'),t('صافي الربح','Net profit'),
      t('الأصول بداية الفترة','Beginning total assets'),t('حقوق الملكية بداية الفترة','Beginning equity'),
      t('المخزون بداية الفترة','Beginning inventory')
    ];
    double? v(int i){
      final s=fields[i].text.trim().replaceAll(',','');
      final x=double.tryParse(s);
      return x!=null && x.isFinite?x:null;
    }
    double? ratio(List<int> indices,double? Function(List<double>) calc){
      final vals=<double>[];
      for(final i in indices){final n=v(i);if(n==null)return null;vals.add(n);}
      final n=calc(vals);
      return n!=null && n.isFinite?n:null;
    }
    final results=<({String group,String name,double? value,bool percent})>[];
    void add(String group,String ar,String en,List<int> ids,double? Function(List<double>) fn,{bool percent=false}){
      results.add((group:group,name:t(ar,en),value:ratio(ids,fn),percent:percent));
    }
    final liquidity=t('السيولة','Liquidity'), leverage=t('المديونية','Leverage'),profit=t('الربحية','Profitability'),eff=t('الكفاءة','Efficiency');
    add(liquidity,'نسبة التداول','Current ratio',[0,3],(a)=>a[1]>0?AccountingMetrics.currentRatio(a[0],a[1]):null);
    add(liquidity,'نسبة السيولة السريعة','Quick ratio',[0,1,3],(a)=>a[2]>0?AccountingMetrics.quickRatio(a[0],a[1],a[2]):null);
    add(liquidity,'نسبة النقدية','Cash ratio',[2,3],(a)=>a[1]>0?AccountingMetrics.cashRatio(a[0],a[1]):null);
    add(leverage,'الالتزامات إلى حقوق الملكية','Liabilities to equity',[4,6],(a)=>a[1]>0?AccountingMetrics.debtToEquity(a[0],a[1]):null);
    add(leverage,'نسبة المديونية','Debt ratio',[4,5],(a)=>a[1]>0?AccountingMetrics.debtRatio(a[0],a[1]):null,percent:true);
    add(profit,'هامش مجمل الربح','Gross margin',[7,8],(a)=>a[0]>0?AccountingMetrics.grossMargin(a[0],a[1]):null,percent:true);
    add(profit,'هامش صافي الربح','Net margin',[9,7],(a)=>a[1]>0?AccountingMetrics.netMargin(a[0],a[1]):null,percent:true);
    add(profit,'العائد على متوسط الأصول','Return on average assets',[9,10,5],(a)=>(a[1]+a[2])>0?AccountingMetrics.roa(a[0],(a[1]+a[2])/2):null,percent:true);
    add(profit,'العائد على متوسط حقوق الملكية','Return on average equity',[9,11,6],(a)=>(a[1]+a[2])>0?AccountingMetrics.roe(a[0],(a[1]+a[2])/2):null,percent:true);
    add(eff,'دوران متوسط الأصول','Average asset turnover',[7,10,5],(a)=>(a[1]+a[2])>0?AccountingMetrics.assetTurnover(a[0],(a[1]+a[2])/2):null);
    add(eff,'دوران متوسط المخزون','Average inventory turnover',[8,12,1],(a)=>(a[1]+a[2])>0?AccountingMetrics.inventoryTurnover(a[0],(a[1]+a[2])/2):null);
    return ListView(padding:const EdgeInsets.all(12),children:[
      Text(t('التحليل المالي الشامل','Comprehensive financial analysis'),style:Theme.of(context).textTheme.titleLarge),
      const SizedBox(height:8),
      Text(t('أدخل البيانات المتوفرة مرة واحدة. اترك الحقول غير المتوفرة فارغة، وستظهر النسب التي لا يمكن حسابها بوضوح.','Enter available data once. Leave unavailable fields blank; ratios missing data will be identified.')),
      const SizedBox(height:12),
      for(var i=0;i<labels.length;i++)Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(
        controller:fields[i],keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),
        onChanged:(_)=>setState(()=>calculated=false),
        decoration:InputDecoration(labelText:labels[i],border:const OutlineInputBorder()))),
      FilledButton(onPressed:()=>setState(()=>calculated=true),child:Text(t('احسب جميع النسب','Calculate all ratios'))),
      if(calculated)...[
        const SizedBox(height:12),
        for(final group in [liquidity,leverage,profit,eff])...[
          Padding(padding:const EdgeInsets.symmetric(vertical:10),child:Text(group,style:Theme.of(context).textTheme.titleMedium)),
          for(final r in results.where((r)=>r.group==group))
            Card(child:ListTile(title:Text(r.name),subtitle:Text(r.value==null?t('بيانات غير كافية أو مقام غير صالح','Missing data or invalid denominator'):'${r.value!.toStringAsFixed(2)}${r.percent?'%':''}'))),
        ]
      ]
    ]);
  }
}
