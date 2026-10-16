import 'feasibility_analysis.dart';
import 'package:flutter/material.dart';

enum FeasibilityKind { revenue, operatingFixed, operatingVariable, startup, investment }
enum FeasibilityFrequency { once, monthly, yearly }

class FeasibilityItem {
  final String category;
  final String description;
  final FeasibilityKind kind;
  final FeasibilityFrequency frequency;
  final double quantity;
  final double unitPrice;
  const FeasibilityItem({required this.category,required this.description,required this.kind,required this.frequency,required this.quantity,required this.unitPrice});
  double get total=>quantity*unitPrice;
  double get annual=>total*(frequency==FeasibilityFrequency.monthly?12:1);
}

class FeasibilityModel {
  static double annualRevenue(Iterable<FeasibilityItem> items)=>items.where((e)=>e.kind==FeasibilityKind.revenue).fold(0,(s,e)=>s+e.annual);
  static double annualOperatingCosts(Iterable<FeasibilityItem> items)=>items.where((e)=>e.kind==FeasibilityKind.operatingFixed || e.kind==FeasibilityKind.operatingVariable).fold(0,(s,e)=>s+e.annual);
  static double initialOutlay(Iterable<FeasibilityItem> items)=>items.where((e)=>e.kind==FeasibilityKind.startup || e.kind==FeasibilityKind.investment).fold(0,(s,e)=>s+e.total);
  static double operatingSurplus(Iterable<FeasibilityItem> items)=>annualRevenue(items)-annualOperatingCosts(items);
  static double? simplePayback(Iterable<FeasibilityItem> items){
    final surplus=operatingSurplus(items);
    return surplus>0?initialOutlay(items)/surplus:null;
  }
}

class FeasibilityScreen extends StatefulWidget {
  final bool en;
  const FeasibilityScreen({super.key,required this.en});
  @override State<FeasibilityScreen> createState()=>_FeasibilityState();
}
class _FeasibilityState extends State<FeasibilityScreen>{
  final items=<FeasibilityItem>[];
  final category=TextEditingController(),description=TextEditingController(),quantity=TextEditingController(text:'1'),price=TextEditingController();
  FeasibilityKind kind=FeasibilityKind.operatingFixed;
  FeasibilityFrequency frequency=FeasibilityFrequency.monthly;
  int? editing;
  final discountRate=TextEditingController(text:'10');
  final growthRate=TextEditingController(text:'0');
  final costGrowthRate=TextEditingController(text:'0');
  final years=TextEditingController(text:'5');
  final recovery=TextEditingController(text:'0');
  bool showProjection=false;
  String? error;
  String t(String ar,String en)=>widget.en?en:ar;
  String kindName(FeasibilityKind k)=>switch(k){
    FeasibilityKind.revenue=>t('إيرادات','Revenue'),
    FeasibilityKind.operatingFixed=>t('مصروف تشغيلي ثابت','Fixed operating expense'),
    FeasibilityKind.operatingVariable=>t('مصروف تشغيلي متغير','Variable operating expense'),
    FeasibilityKind.startup=>t('مصروف تأسيسي','Startup expense'),
    FeasibilityKind.investment=>t('استثمار أولي','Capital investment')
  };
  String frequencyName(FeasibilityFrequency f)=>switch(f){
    FeasibilityFrequency.once=>t('مرة واحدة','One-time'),
    FeasibilityFrequency.monthly=>t('شهري','Monthly'),
    FeasibilityFrequency.yearly=>t('سنوي','Yearly')
  };
  @override void dispose(){category.dispose();description.dispose();quantity.dispose();price.dispose();discountRate.dispose();growthRate.dispose();costGrowthRate.dispose();years.dispose();recovery.dispose();super.dispose();}
  void reset(){
    category.clear();description.clear();quantity.text='1';price.clear();kind=FeasibilityKind.operatingFixed;frequency=FeasibilityFrequency.monthly;editing=null;error=null;
  }
  void save(){
    final q=double.tryParse(quantity.text.trim().replaceAll(',',''));
    final p=double.tryParse(price.text.trim().replaceAll(',',''));
    if(category.text.trim().isEmpty || description.text.trim().isEmpty || q==null || p==null || !q.isFinite || !p.isFinite || q<=0 || p<0 ||
      ((kind==FeasibilityKind.startup || kind==FeasibilityKind.investment) && frequency!=FeasibilityFrequency.once) ||
      ((kind==FeasibilityKind.revenue || kind==FeasibilityKind.operatingFixed || kind==FeasibilityKind.operatingVariable) && frequency==FeasibilityFrequency.once)){
      setState(()=>error=t('أدخل تصنيفًا ووصفًا وقيمًا صالحة، وتأكد من دورية البند','Enter a category, description, valid amounts and matching frequency'));return;
    }
    final item=FeasibilityItem(category:category.text.trim(),description:description.text.trim(),kind:kind,frequency:frequency,quantity:q,unitPrice:p);
    setState((){if(editing==null){items.add(item);}else{items[editing!]=item;}reset();});
  }
  void edit(int i){final x=items[i];setState((){
    editing=i;category.text=x.category;description.text=x.description;quantity.text=x.quantity.toString();price.text=x.unitPrice.toString();kind=x.kind;frequency=x.frequency;error=null;
  });}
  @override Widget build(BuildContext context){
    final revenue=FeasibilityModel.annualRevenue(items),costs=FeasibilityModel.annualOperatingCosts(items),initial=FeasibilityModel.initialOutlay(items),surplus=FeasibilityModel.operatingSurplus(items);
    final payback=FeasibilityModel.simplePayback(items);
    return ListView(padding:const EdgeInsets.all(12),children:[
      Text(t('دراسة جدوى مشروع — البنود المرنة','Project feasibility — flexible line items'),style:Theme.of(context).textTheme.titleLarge),
      const SizedBox(height:8),
      Text(t('أضف أي تصنيف وبند إيراد أو مصروف أو استثمار. هذا تقدير تشغيلي أولي، وليس دراسة جدوى نهائية.','Add custom revenue, expense or investment categories. This is an initial operating estimate, not a complete feasibility study.')),
      const SizedBox(height:12),
      TextField(controller:category,decoration:InputDecoration(labelText:t('اسم التصنيف المخصص','Custom category'),border:const OutlineInputBorder())),
      const SizedBox(height:8),
      TextField(controller:description,decoration:InputDecoration(labelText:t('وصف البند','Line item description'),border:const OutlineInputBorder())),
      const SizedBox(height:8),
      DropdownButtonFormField<FeasibilityKind>(initialValue:kind,isExpanded:true,decoration:InputDecoration(labelText:t('طبيعة البند','Item type'),border:const OutlineInputBorder()),
        items:FeasibilityKind.values.map((k)=>DropdownMenuItem(value:k,child:Text(kindName(k)))).toList(),
        onChanged:(v)=>setState((){kind=v??kind;frequency=(kind==FeasibilityKind.startup || kind==FeasibilityKind.investment)?FeasibilityFrequency.once:FeasibilityFrequency.monthly;})),
      const SizedBox(height:8),
      DropdownButtonFormField<FeasibilityFrequency>(key:ValueKey('${kind.name}-${frequency.name}'),initialValue:frequency,isExpanded:true,decoration:InputDecoration(labelText:t('التكرار','Frequency'),border:const OutlineInputBorder()),
        items:(kind==FeasibilityKind.startup || kind==FeasibilityKind.investment?[FeasibilityFrequency.once]:[FeasibilityFrequency.monthly,FeasibilityFrequency.yearly])
          .map((f)=>DropdownMenuItem(value:f,child:Text(frequencyName(f)))).toList(),
        onChanged:(v)=>setState(()=>frequency=v??frequency)),
      const SizedBox(height:8),
      Row(children:[
        Expanded(child:TextField(controller:quantity,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:t('الكمية','Quantity'),border:const OutlineInputBorder()))),
        const SizedBox(width:8),
        Expanded(child:TextField(controller:price,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:t('سعر الوحدة','Unit price'),border:const OutlineInputBorder()))),
      ]),
      if(error!=null)Padding(padding:const EdgeInsets.all(8),child:Text(error!,style:TextStyle(color:Theme.of(context).colorScheme.error))),
      const SizedBox(height:10),
      FilledButton.icon(onPressed:save,icon:Icon(editing==null?Icons.add:Icons.save),label:Text(editing==null?t('إضافة البند','Add item'):t('حفظ التعديل','Save changes'))),
      if(editing!=null)TextButton(onPressed:()=>setState(reset),child:Text(t('إلغاء التعديل','Cancel editing'))),
      const Divider(),
      for(var i=0;i<items.length;i++)Card(child:ListTile(
        title:Text('${items[i].category} — ${items[i].description}'),
        subtitle:Text('${kindName(items[i].kind)} • ${frequencyName(items[i].frequency)} • ${items[i].total.toStringAsFixed(2)}'),
        trailing:Wrap(spacing:0,children:[
          IconButton(tooltip:t('تعديل','Edit'),onPressed:()=>edit(i),icon:const Icon(Icons.edit_outlined)),
          IconButton(tooltip:t('حذف','Delete'),onPressed:()=>setState((){items.removeAt(i);reset();}),icon:const Icon(Icons.delete_outline)),
        ]))),
      const Divider(),
      for(final entry in [
        (t('الإيرادات السنوية','Annual revenue'),revenue),
        (t('المصروفات التشغيلية السنوية','Annual operating costs'),costs),
        (t('الاستثمار والمصاريف التأسيسية','Initial investment and startup costs'),initial),
        (t('الفائض التشغيلي قبل الإهلاك والتمويل والضرائب','Operating surplus before depreciation, finance and tax'),surplus)
      ])ListTile(title:Text(entry.$1),trailing:Text(entry.$2.toStringAsFixed(2))),
      ListTile(title:Text(t('الاسترداد البسيط التقريبي','Approximate simple payback')),subtitle:Text(payback==null?t('غير متاح دون فائض تشغيلي موجب','Unavailable without positive operating surplus'):'${payback.toStringAsFixed(2)} ${t('سنة','years')}')),
      const Divider(),
      Text(t('التوقعات المالية متعددة السنوات','Multi-year financial forecast'),style:Theme.of(context).textTheme.titleMedium),
      const SizedBox(height:8),
      for(final pair in [
        (years,t('عدد سنوات الدراسة (1–30)','Forecast years (1–30)')),
        (discountRate,t('معدل الخصم السنوي %','Annual discount rate %')),
        (growthRate,t('نمو الإيرادات السنوي %','Annual revenue growth %')),
        (costGrowthRate,t('نمو التكاليف السنوي %','Annual cost growth %')),
        (recovery,t('القيمة المستردة في نهاية المشروع','Terminal recovery value'))
      ])Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(
        controller:pair.$1,keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),
        onChanged:(_)=>setState(()=>showProjection=false),
        decoration:InputDecoration(labelText:pair.$2,border:const OutlineInputBorder()))),
      FilledButton(onPressed:()=>setState(()=>showProjection=true),child:Text(t('تحليل التدفقات والجدوى','Analyze cash flows and feasibility'))),
      if(showProjection)Builder(builder:(context){
        final n=int.tryParse(years.text.trim());
        final rate=double.tryParse(discountRate.text.trim());
        final rg=double.tryParse(growthRate.text.trim());
        final cg=double.tryParse(costGrowthRate.text.trim());
        final terminal=double.tryParse(recovery.text.trim());
        if(n==null || n<1 || n>30 || rate==null || rg==null || cg==null || terminal==null ||
           !rate.isFinite || !rg.isFinite || !cg.isFinite || !terminal.isFinite ||
           rate<=-100 || rg<=-100 || cg<=-100 || terminal<0){
          return Padding(padding:const EdgeInsets.all(12),child:Text(t('تحقق من سنوات الدراسة والمعدلات والقيمة المستردة','Check forecast years, rates and terminal value')));
        }
        final flows=FeasibilityAnalysis.projection(investment:initial,annualRevenue:revenue,
          annualOperatingCosts:costs,years:n,revenueGrowth:rg/100,costGrowth:cg/100,terminalRecovery:terminal);
        final npv=FeasibilityAnalysis.npv(rate/100,flows);
        final irr=FeasibilityAnalysis.irr(flows);
        final discounted=FeasibilityAnalysis.discountedPayback(rate/100,flows);
        return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          ListTile(title:const Text('NPV'),subtitle:Text(npv.toStringAsFixed(2))),
          ListTile(title:const Text('IRR'),subtitle:Text(irr==null?t('غير متاح','Unavailable'):'${(irr*100).toStringAsFixed(2)}%')),
          ListTile(title:Text(t('الاسترداد المخصوم','Discounted payback')),
            subtitle:Text(discounted==null?t('لا يُسترد خلال مدة الدراسة','Not recovered during forecast'):'${discounted.toStringAsFixed(2)} ${t('سنة','years')}')),
          Text(t('التدفقات النقدية السنوية (السنة صفر = الاستثمار الأولي)','Annual cash flows (year zero = initial outlay)')),
          for(var i=0;i<flows.length;i++)ListTile(dense:true,title:Text('${t('السنة','Year')} $i'),trailing:Text(flows[i].toStringAsFixed(2))),
          Text(t('النتائج افتراضية مبسطة قبل التمويل والضرائب ورأس المال العامل؛ لا تصلح وحدها لاتخاذ قرار استثماري.','Simplified unlevered, pre-tax projection excluding working capital; not sufficient alone for an investment decision.'))
        ]);
      }),
      Text(t('تنبيه: لا تشمل هذه النسخة الضرائب أو رأس المال العامل أو توقيت التدفقات أو القيمة الزمنية للنقود. البيانات محفوظة في هذه الشاشة فقط حاليًا.','Note: tax, working capital, cash-flow timing and time value of money are not included. Data currently stays in this screen only.'))
    ]);
  }
}
