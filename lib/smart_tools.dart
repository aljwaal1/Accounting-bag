import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmartTools extends StatefulWidget {
  final bool en;
  const SmartTools({super.key, required this.en});
  @override State<SmartTools> createState()=>_SmartToolsState();
}
class _SmartToolsState extends State<SmartTools>{
  int mode=0, selected=0;
  final amount=TextEditingController(), rate=TextEditingController(), other=TextEditingController();
  String t(String ar,String en)=>widget.en?en:ar;
  @override void dispose(){amount.dispose();rate.dispose();other.dispose();super.dispose();}
  double? read(TextEditingController c){
    final v=double.tryParse(c.text.trim().replaceAll(',',''));
    return v!=null&&v.isFinite&&v>=0?v:null;
  }
  @override Widget build(BuildContext context){
    final cases=[
      [t('بيع خدمة نقدًا','Cash service sale'),t('النقدية','Cash'),t('إيراد الخدمات','Service revenue')],
      [t('بيع خدمة آجلًا','Credit service sale'),t('العملاء','Receivables'),t('إيراد الخدمات','Service revenue')],
      [t('شراء أصل نقدًا','Cash asset purchase'),t('الأصول الثابتة','Property and equipment'),t('النقدية','Cash')],
      [t('شراء مخزون آجلًا (جرد مستمر)','Credit inventory purchase (perpetual)'),t('المخزون','Inventory'),t('الموردون','Payables')],
      [t('تحصيل من عميل','Collect receivable'),t('النقدية','Cash'),t('العملاء','Receivables')],
      [t('سداد مورد','Pay supplier'),t('الموردون','Payables'),t('النقدية','Cash')],
      [t('دفع إيجار الفترة','Pay current rent'),t('مصروف الإيجار','Rent expense'),t('النقدية','Cash')],
      [t('إيداع رأس مال نقدي','Cash capital contribution'),t('النقدية','Cash'),t('رأس المال','Capital')],
      [t('استلام قرض','Receive loan'),t('النقدية','Cash'),t('القروض','Loans payable')],
      [t('إثبات إهلاك','Record depreciation'),t('مصروف الإهلاك','Depreciation expense'),t('مجمع الإهلاك','Accumulated depreciation')],
      [t('إثبات أجور مستحقة','Accrue wages'),t('مصروف الأجور','Wages expense'),t('أجور مستحقة','Wages payable')],
      [t('دفع تأمين مقدم','Prepay insurance'),t('تأمين مقدم','Prepaid insurance'),t('النقدية','Cash')],
      [t('تسوية التأمين المستنفد','Recognize expired insurance'),t('مصروف التأمين','Insurance expense'),t('تأمين مقدم','Prepaid insurance')],
      [t('استلام دفعة قبل تقديم الخدمة','Receive advance for service'),t('النقدية','Cash'),t('إيراد مؤجل','Deferred revenue')],
      [t('إثبات الخدمة المنجزة من دفعة مقدمة','Recognize earned advance'),t('إيراد مؤجل','Deferred revenue'),t('إيراد الخدمات','Service revenue')],
    ];
    final a=read(amount),b=read(rate),c=read(other);
    String? result;
    if(mode==0&&a!=null&&a>0){
      final entry=cases[selected];
      result='${t("مدين","Debit")}: ${entry[1]} — ${a.toStringAsFixed(2)}\n${t("دائن","Credit")}: ${entry[2]} — ${a.toStringAsFixed(2)}\n${t("الفرق: صفر — القيد متوازن","Difference: zero — balanced entry")}';
    }else if(mode==1&&a!=null&&a>0&&b!=null&&b<100&&c!=null){
      final price=a/(1-b/100), tax=price*c/100;
      if(price.isFinite&&tax.isFinite&&(price+tax).isFinite){
        result='${t("سعر البيع قبل الضريبة","Price before tax")}: ${price.toStringAsFixed(2)}\n${t("ربح الوحدة","Unit profit")}: ${(price-a).toStringAsFixed(2)}\n${t("الضريبة","Tax")}: ${tax.toStringAsFixed(2)}\n${t("السعر النهائي","Final price")}: ${(price+tax).toStringAsFixed(2)}';
      }
    }else if(mode==2&&a!=null&&b!=null){
      final diff=a-b;
      result='${t("فرق المدين والدائن","Debit less credit")}: ${diff.toStringAsFixed(2)}\n${diff.abs()<0.005?t("متوازن حسابيًا؛ لا يثبت صحة التصنيف","Arithmetically balanced; classification not verified"):t("راجع مصدر الفرق ولا تسجل قيدًا وهميًا","Investigate the difference; do not post a fictitious entry")}';
    }
    Widget field(TextEditingController ctrl,String label)=>Padding(padding:const EdgeInsets.only(bottom:12),child:TextField(controller:ctrl,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:label),onChanged:(_)=>setState((){})));
    return ListView(padding:const EdgeInsets.all(12),children:[
      Wrap(spacing:8,runSpacing:8,children:List.generate(3,(i)=>ChoiceChip(label:Text([t('القيود الذكية','Smart entries'),t('التسعير','Pricing'),t('فحص التوازن','Balance check')][i]),selected:mode==i,onSelected:(_)=>setState((){mode=i;amount.clear();rate.clear();other.clear();})))),
      const SizedBox(height:12),
      if(mode==0)...[
        DropdownButtonFormField<int>(initialValue:selected,isExpanded:true,items:List.generate(cases.length,(i)=>DropdownMenuItem(value:i,child:Text(cases[i][0],overflow:TextOverflow.ellipsis))),onChanged:(v)=>setState(()=>selected=v??0)),
        const SizedBox(height:12),
        field(amount,t('المبلغ دون ضريبة','Amount excluding tax')),
        Text(t('أمثلة مبسطة دون ضرائب أو خصومات؛ اختر الحالة المطابقة للعملية.','Simplified examples without taxes or discounts; choose the matching transaction.')),
      ],
      if(mode==1)...[
        field(amount,t('تكلفة الوحدة','Unit cost')),
        field(rate,t('هامش الربح المستهدف % من سعر البيع','Target margin % of selling price')),
        field(other,t('ضريبة المبيعات % (صفر إن لم توجد)','Sales tax % (zero if none)')),
        Text(t('سعر البيع = التكلفة ÷ (1 − هامش الربح). الهامش أقل من 100%.','Price = cost / (1 − margin). Margin must be below 100%.')),
      ],
      if(mode==2)...[field(amount,t('إجمالي المدين','Total debit')),field(rate,t('إجمالي الدائن','Total credit'))],
      if(result!=null)Card(color:const Color(0xffe5f5ef),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[SelectableText(result,style:const TextStyle(fontSize:17)),TextButton.icon(onPressed:()=>Clipboard.setData(ClipboardData(text:result!)),icon:const Icon(Icons.copy),label:Text(t('نسخ النتيجة','Copy result')))]))),
    ]);
  }
}
