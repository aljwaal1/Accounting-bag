import 'package:flutter/material.dart';
import 'number_input.dart';

/// Simplified management tools, not a complete IFRS financial statement.
class ProfessionalMath {
  static List<double> income(double revenue,double cost,double operating,double investing,double financing,double tax) {
    final gross=revenue-cost, op=gross-operating;
    return [gross,op,op+investing,op+investing+financing,op+investing+financing-tax];
  }
  static double cashFlow(double opening,double operating,double investing,double financing,double exchange)=>opening+operating+investing+financing+exchange;
  static double contribution(double sales,double variable)=>sales-variable;
  static double balance(double assets,double liabilities,double equity)=>assets-liabilities-equity;
  static double? breakEven(double fixed,double price,double variable)=>price>variable?fixed/(price-variable):null;
  static double? nrvWriteDown(double cost,double selling,double completion,double sellingCost)=>(cost-(selling-completion-sellingCost)).clamp(0.0,cost).toDouble();
  static double vatInclusive(double gross,double rate)=>gross-gross/(1+rate/100);
  static double? wacc(double equity,double debt,double ke,double kd,double tax)=>equity+debt>0?(equity*ke+debt*kd*(1-tax/100))/(equity+debt):null;
}
class ProfessionalTools extends StatefulWidget {
  final bool en;
  const ProfessionalTools({super.key,required this.en});
  @override State<ProfessionalTools> createState()=>_ProfessionalToolsState();
}
class _ProfessionalToolsState extends State<ProfessionalTools>{
  int mode=0;
  final fields=List.generate(6,(_)=>TextEditingController());
  String t(String ar,String en)=>widget.en?en:ar;
  @override void dispose(){for(final c in fields){c.dispose();}super.dispose();}
  @override Widget build(BuildContext context){
    final names=[t('قائمة الدخل IFRS 18','IFRS 18 income'),t('المركز المالي','Financial position'),t('نقطة التعادل','Break-even'),t('انخفاض المخزون IAS 2','IAS 2 inventory'),t('ضريبة شاملة','Inclusive VAT'),t('تكلفة رأس المال WACC','WACC'),t('التدفقات النقدية IAS 7','IAS 7 cash flows'),t('هامش المساهمة','Contribution margin')];
    final labels=[
      [t('الإيرادات','Revenue'),t('تكلفة المبيعات','Cost of sales'),t('صافي المصروفات التشغيلية','Net operating expenses'),t('صافي نتيجة الاستثمار (موقعة)','Net investing result (signed)'),t('صافي نتيجة التمويل (موقعة)','Net financing result (signed)'),t('مصروف ضريبة الدخل','Income tax expense')],
      [t('الأصول','Assets'),t('الالتزامات','Liabilities'),t('حقوق الملكية (موقعة)','Equity (signed)')],
      [t('التكاليف الثابتة','Fixed costs'),t('سعر الوحدة','Unit price'),t('التكلفة المتغيرة للوحدة','Variable unit cost')],
      [t('تكلفة المخزون','Inventory cost'),t('سعر البيع المتوقع','Expected selling price'),t('تكلفة الإكمال','Completion cost'),t('تكلفة البيع','Selling cost')],
      [t('المبلغ شامل الضريبة','Tax-inclusive amount'),t('نسبة الضريبة %','Tax rate %')],
      [t('القيمة السوقية لحقوق الملكية','Market equity'),t('القيمة السوقية للدين','Market debt'),t('تكلفة الملكية %','Cost of equity %'),t('تكلفة الدين %','Cost of debt %'),t('معدل الضريبة %','Tax rate %')],
      [t('رصيد النقد أول الفترة','Opening cash'),t('صافي التدفقات التشغيلية','Net operating cash flows'),t('صافي التدفقات الاستثمارية','Net investing cash flows'),t('صافي التدفقات التمويلية','Net financing cash flows'),t('أثر تغير أسعار الصرف','Exchange rate effect')],
      [t('المبيعات','Sales'),t('التكاليف المتغيرة','Variable costs'),t('التكاليف الثابتة','Fixed costs')]
    ][mode];
    final values=List.generate(labels.length,(i)=>parseAccountingNumber(fields[i].text));
    final signed=mode==0?[2,3,4,5]:mode==1?[2]:mode==6?[1,2,3,4]:<int>[];
    final valid=values.asMap().entries.every((e)=>e.value!=null&&(signed.contains(e.key)||e.value!>=0));
    final results=<String>[];
    void add(String label,double? value,{String suffix=''}){results.add('$label: ${value!=null&&value.isFinite?value.toStringAsFixed(2)+suffix:t("غير معرف","Undefined")}');}
    if(valid){
      final v=values.cast<double>();
      switch(mode){
        case 0:
          final r=ProfessionalMath.income(v[0],v[1],v[2],v[3],v[4],v[5]);
          add(t('مجمل الربح','Gross profit'),r[0]);add(t('الربح التشغيلي','Operating profit'),r[1]);add(t('الربح قبل التمويل وضريبة الدخل','Profit before financing and income taxes'),r[2]);add(t('الربح قبل الضريبة','Profit before tax'),r[3]);add(t('ربح الفترة','Profit for period'),r[4]);break;
        case 1:add(t('فرق المعادلة','Equation difference'),ProfessionalMath.balance(v[0],v[1],v[2]));break;
        case 2:final r=ProfessionalMath.breakEven(v[0],v[1],v[2]);add(t('وحدات التعادل','Break-even units'),r==null||!r.isFinite?null:r.ceilToDouble());break;
        case 3:add(t('صافي القيمة القابلة للتحقق','Net realizable value'),v[1]-v[2]-v[3]);add(t('تخفيض قيمة المخزون','Inventory write-down'),ProfessionalMath.nrvWriteDown(v[0],v[1],v[2],v[3]));break;
        case 4:final tax=ProfessionalMath.vatInclusive(v[0],v[1]);add(t('الضريبة','Tax'),tax);add(t('المبلغ قبل الضريبة','Net amount'),v[0]-tax);break;
        case 5:if(v[4]<=100)add('WACC',ProfessionalMath.wacc(v[0],v[1],v[2],v[3],v[4]),suffix:'%');break;
        case 6:add(t('صافي تغير النقد قبل أثر الصرف','Net cash change before exchange effect'),v[1]+v[2]+v[3]);add(t('رصيد النقد آخر الفترة','Closing cash'),ProfessionalMath.cashFlow(v[0],v[1],v[2],v[3],v[4]));break;
        case 7:final margin=ProfessionalMath.contribution(v[0],v[1]);add(t('هامش المساهمة','Contribution margin'),margin);add(t('نسبة هامش المساهمة','Contribution margin ratio'),v[0]>0?margin/v[0]*100:null,suffix:'%');add(t('النتيجة التشغيلية المبسطة','Simplified operating result'),margin-v[2]);break;
      }
    }
    return ListView(padding:const EdgeInsets.all(12),children:[
      Wrap(spacing:6,runSpacing:4,children:[for(var i=0;i<names.length;i++)ChoiceChip(label:Text(names[i]),selected:mode==i,onSelected:(_)=>setState((){mode=i;for(final c in fields){c.clear();}}))]),
      const SizedBox(height:12),
      if(mode==0)Text(t('نموذج مبسط لمنشأة غير مالية دون عمليات متوقفة. IFRS 18 يسري للفترات التي تبدأ في 1 يناير 2027 أو بعده، مع السماح بالتطبيق المبكر. لا يمثل قائمة مكتملة أو تصنيفًا لجميع المنشآت.','Simplified non-financial entity without discontinued operations. IFRS 18 applies from 1 January 2027, early application permitted. Not a complete statement or universal classification.')),
      if(mode==6)Text(t('تسوية مبسطة للنقد والنقد المعادل وفق IAS 7، وليست قائمة تدفقات كاملة. أدخل صافي التدفقات بإشاراتها بعد تصنيفها.','Simplified IAS 7 cash and cash equivalents reconciliation, not a complete statement. Enter signed net flows after classification.')),
      if(mode==3)Text(t('تخفيض المخزون لا يتجاوز تكلفته؛ افحص أي التزام إضافي بصورة منفصلة.','Write-down capped at inventory cost; assess additional obligations separately.')),
      for(var i=0;i<labels.length;i++)Padding(padding:const EdgeInsets.symmetric(vertical:5),child:TextField(controller:fields[i],keyboardType:TextInputType.numberWithOptions(decimal:true,signed:signed.contains(i)),decoration:InputDecoration(labelText:labels[i]),onChanged:(_)=>setState((){}))),
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Text(results.isEmpty?t('أدخل قيمًا صحيحة','Enter valid values'):results.join('\n'),style:const TextStyle(fontSize:16)))),
    ]);
  }
}
