import 'package:flutter/material.dart';
import 'accounting_metrics.dart';

class ComprehensiveRatiosScreen extends StatefulWidget {
  final bool en;
  const ComprehensiveRatiosScreen({super.key,required this.en});
  @override State<ComprehensiveRatiosScreen> createState()=>_ComprehensiveRatiosState();
}
class _ComprehensiveRatiosState extends State<ComprehensiveRatiosScreen> {
  final fields=List.generate(13,(_)=>TextEditingController());
  final previousFields=List.generate(13,(_)=>TextEditingController());
  bool compare=false;
  bool calculated=false;
  String t(String ar,String en)=>widget.en?en:ar;
  @override void dispose(){for(final f in [...fields,...previousFields]){f.dispose();}super.dispose();}
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
    Map<int,double> resolved({bool previous=false}) {
      final source=previous?previousFields:fields;
      final values=<int,double>{};
      for(var i=0;i<source.length;i++){
        final raw=source[i].text.trim().replaceAll(',','');
        final number=double.tryParse(raw);
        if(raw.isNotEmpty && number!=null && number.isFinite)values[i]=number;
      }
      // Accounting equation: assets = liabilities + equity.
      if(!values.containsKey(5) && values.containsKey(4) && values.containsKey(6)){
        values[5]=values[4]!+values[6]!;
      }else if(!values.containsKey(4) && values.containsKey(5) && values.containsKey(6)){
        values[4]=values[5]!-values[6]!;
      }else if(!values.containsKey(6) && values.containsKey(5) && values.containsKey(4)){
        values[6]=values[5]!-values[4]!;
      }
      return values;
    }
    void autoFill(List<TextEditingController> source){
      double? read(int i){
        final x=double.tryParse(source[i].text.trim().replaceAll(',',''));
        return x!=null && x.isFinite?x:null;
      }
      final assets=read(5),liabilities=read(4),equity=read(6);
      // Never overwrite user-entered values: if all three are present
      // and inconsistent, there is no evidence identifying the incorrect one.
      if(assets==null && source[5].text.trim().isEmpty && liabilities!=null && equity!=null){
        source[5].text=(liabilities+equity).toStringAsFixed(2);
      }else if(liabilities==null && source[4].text.trim().isEmpty && assets!=null && equity!=null){
        source[4].text=(assets-equity).toStringAsFixed(2);
      }else if(equity==null && source[6].text.trim().isEmpty && assets!=null && liabilities!=null){
        source[6].text=(assets-liabilities).toStringAsFixed(2);
      }
    }
    final current=resolved();
    final prior=compare?resolved(previous:true):<int,double>{};
    double? v(int i,{bool previous=false})=>(previous?prior:current)[i];
    List<String> validate(Map<int,double> data,List<TextEditingController> source){
      final problems=<String>[];
      for(var i=0;i<source.length;i++){
        final raw=source[i].text.trim().replaceAll(',','');
        if(raw.isNotEmpty && (!data.containsKey(i) || !data[i]!.isFinite)){
          problems.add(t('القيمة المدخلة غير صالحة في: ','Invalid value for: ')+labels[i]);
        }
      }
      final a=data[5],l=data[4],e=data[6];
      bool differs(double x,double y)=> (x-y).abs()>0.01+0.000001*[x.abs(),y.abs()].reduce((a,b)=>a>b?a:b);
      if(a!=null && l!=null && e!=null && differs(a,l+e)){
        problems.add(t('الميزانية غير متوازنة: الفرق = ','Balance sheet does not balance: difference = ')+(a-l-e).toStringAsFixed(2));
      }
      for(final pair in <(int,int)>[(1,0),(2,0),(3,4),(0,5)]){
        final part=data[pair.$1],whole=data[pair.$2];
        if(part!=null && whole!=null && part>whole+0.01){
          problems.add(labels[pair.$1]+t(' لا يمكن أن يتجاوز ',' cannot exceed ')+labels[pair.$2]);
        }
      }
      if(data[7]!=null && data[8]!=null && data[8]!>data[7]!){
        // A gross loss is possible; do not reject it.
      }
      for(final i in <int>[0,1,2,3,4,5,7,8,10,12]){
        if(data[i]!=null && data[i]!<0){
          problems.add(labels[i]+t(' لا يمكن أن يكون سالبًا',' cannot be negative'));
        }
      }
      return problems;
    }
    final errors=[...validate(current,fields),if(compare)...validate(prior,previousFields)];
    double? ratio(List<int> indices,double? Function(List<double>) calc,{bool previous=false}){
      final vals=<double>[];
      for(final i in indices){final n=v(i,previous:previous);if(n==null)return null;vals.add(n);}
      final n=calc(vals);
      return n!=null && n.isFinite?n:null;
    }
    final results=<({String group,String name,double? value,double? previous,bool percent})>[];
    void add(String group,String ar,String en,List<int> ids,double? Function(List<double>) fn,{bool percent=false}){
      results.add((group:group,name:t(ar,en),value:ratio(ids,fn),previous:compare?ratio(ids,fn,previous:true):null,percent:percent));
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
    return Column(children:[Expanded(child:ListView(padding:const EdgeInsets.all(12),children:[
      Text(t('التحليل المالي الشامل','Comprehensive financial analysis'),style:Theme.of(context).textTheme.titleLarge),
      const SizedBox(height:8),
      Text(t('أدخل البيانات المتوفرة. يستنتج التطبيق إجمالي الأصول أو الالتزامات أو حقوق الملكية إذا توفرت القيمتان الأخريان، ويمنع التحليل عند وجود عدم توازن.','Enter available data. Assets, liabilities or equity are derived when the other two are provided. Unbalanced inputs block analysis.')),
      SwitchListTile(title:Text(t('مقارنة مع فترة سابقة','Compare with previous period')),value:compare,onChanged:(v)=>setState((){compare=v;calculated=false;})),
      Text(t('بيانات الفترة الحالية','Current period inputs'),style:Theme.of(context).textTheme.titleMedium),
      const SizedBox(height:12),
      for(var i=0;i<labels.length;i++)Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(
        controller:fields[i],keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),
        onChanged:(_)=>setState(()=>calculated=false),
        decoration:InputDecoration(labelText:labels[i],border:const OutlineInputBorder()))),
      if(compare)...[
        Padding(padding:const EdgeInsets.symmetric(vertical:12),child:Text(t('بيانات الفترة السابقة','Previous period inputs'),style:Theme.of(context).textTheme.titleMedium)),
        for(var i=0;i<labels.length;i++)Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(
          controller:previousFields[i],keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),
          onChanged:(_)=>setState(()=>calculated=false),
          decoration:InputDecoration(labelText:labels[i],border:const OutlineInputBorder()))),
      ],
      if(errors.isNotEmpty)Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t('أخطاء يجب تصحيحها قبل التحليل','Correct these errors before analysis'),style:TextStyle(color:Theme.of(context).colorScheme.error,fontWeight:FontWeight.bold)),for(final message in errors)Text('• $message')]))),
      OutlinedButton.icon(onPressed:()=>setState((){autoFill(fields);if(compare)autoFill(previousFields);calculated=false;}),icon:const Icon(Icons.auto_fix_high),label:Text(t('تعبئة القيم القابلة للاشتقاق تلقائيًا','Auto-fill derivable values'))),
      Text(t('لا يتم تغيير رقم أدخلته يدويًا. إذا كانت القيم متعارضة، يجب مراجعة مصدر البيانات لتحديد الرقم الصحيح.','Manually entered values are never overwritten. Conflicting figures require source verification.')),
      if(current.containsKey(5) || current.containsKey(4) || current.containsKey(6))Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t('الميزانية بعد الاشتقاق الآلي','Balance sheet after automatic derivation')),for(final i in [5,4,6])Text('${labels[i]}: ${current[i]?.toStringAsFixed(2)??t('غير متاح','N/A')}${fields[i].text.trim().isEmpty && current.containsKey(i)?t(' (محسوب تلقائيًا)',' (auto-calculated)'):''}')]))),
      if(calculated && errors.isEmpty)...[
        const SizedBox(height:12),
        for(final group in [liquidity,leverage,profit,eff])...[
          Padding(padding:const EdgeInsets.symmetric(vertical:10),child:Text(group,style:Theme.of(context).textTheme.titleMedium)),
          for(final r in results.where((r)=>r.group==group))
            Card(child:ListTile(title:Text(r.name),subtitle:Text(r.value==null?t('بيانات غير كافية أو مقام غير صالح','Missing data or invalid denominator'):'${r.value!.toStringAsFixed(2)}${r.percent?'%':''}' + (compare?'\n${t('الفترة السابقة','Previous')}: ${r.previous==null?t('غير متاح','N/A'):'${r.previous!.toStringAsFixed(2)}${r.percent?'%':''}'}':'') + (compare && r.value!=null && r.previous!=null?'\n${t('التغير','Change')}: ${(r.value!-r.previous!).toStringAsFixed(2)}${r.percent?t(' نقطة مئوية',' percentage points'):''}':'') + '\n' + (r.value==null?t('أكمل البيانات المطلوبة للحساب','Complete required inputs'):t('تُفسر النسبة بمقارنتها بالفترات السابقة ومعايير القطاع؛ ارتفاعها ليس دائمًا أفضل.','Interpret against historical and industry benchmarks; higher is not always better.'))))),
        ]
      ]
    ])),SafeArea(top:false,child:Padding(padding:const EdgeInsets.fromLTRB(12,6,12,8),child:SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:errors.isEmpty?()=>setState(()=>calculated=true):null,icon:const Icon(Icons.calculate),label:Text(t('احسب جميع النسب','Calculate all ratios'))))))]);
  }
}
