import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart' as xl;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class SmartTools extends StatefulWidget {
  final bool en;
  const SmartTools({super.key, required this.en});
  @override State<SmartTools> createState()=>_SmartToolsState();
}
class _SmartToolsState extends State<SmartTools>{
  int mode=0, selected=0;
  List<String> history=[];
  @override void initState(){super.initState();loadHistory();}
  Future<void> loadHistory() async {
    final p=await SharedPreferences.getInstance();
    if(mounted)setState(()=>history=p.getStringList('smart_history')??[]);
  }
  Future<void> saveResult(String value) async {
    final p=await SharedPreferences.getInstance();
    final items=<String>[value,...(p.getStringList('smart_history')??const <String>[])];
    if(!await p.setStringList('smart_history',items))throw StateError('Save failed');
    if(mounted)setState(()=>history=items);
  }
  Future<void> restoreHistory(String value) async {
    final decoded=jsonDecode(value);
    if(decoded is! List || decoded.any((e)=>e is! String))throw const FormatException();
    final items=List<String>.from(decoded);
    final p=await SharedPreferences.getInstance();
    if(!await p.setStringList('smart_history',items))throw StateError('Save failed');
    if(mounted)setState(()=>history=items);
  }
  Future<void> exportResult(String value, bool pdf) async {
    try {
      if(pdf){
        final doc=pw.Document();
        pw.Font? font;
        if(!widget.en){
          for(final path in ['/system/fonts/NotoNaskhArabic-Regular.ttf','/system/fonts/NotoSansArabic-Regular.ttf']){
            final file=File(path);
            if(await file.exists()){font=pw.Font.ttf(ByteData.sublistView(await file.readAsBytes()));break;}
          }
          if(font==null)throw StateError('Arabic font unavailable');
        }
        doc.addPage(pw.MultiPage(build:(_)=>[
          pw.Directionality(textDirection:widget.en?pw.TextDirection.ltr:pw.TextDirection.rtl,child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.stretch,children:[
            pw.Text(t('الحقيبة المحاسبية','Accounting Bag'),style:pw.TextStyle(font:font,fontSize:22)),
            ...value.split('\n').map((line)=>pw.Padding(padding:const pw.EdgeInsets.all(6),child:pw.Text(line,style:pw.TextStyle(font:font,fontSize:13)))),
          ])),
        ]));
        await Printing.sharePdf(bytes:await doc.save(),filename:'accounting-result.pdf');
      }else{
        final book=xl.Excel.createExcel();
        final sheet=book['Sheet1'];
        sheet.appendRow([xl.TextCellValue(t('النتيجة','Result'))]);
        for(final line in value.split('\n')){
          sheet.appendRow([xl.TextCellValue(line)]);
        }
        final bytes=book.encode();
        if(bytes==null)throw StateError('Excel encoding failed');
        await Share.shareXFiles([XFile.fromData(Uint8List.fromList(bytes),mimeType:'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],fileNameOverrides:['accounting-result.xlsx']);
      }
    }catch(_){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t('تعذر التصدير على هذا الجهاز','Export failed on this device'))));
    }
  }
  Future<void> showHistory() async {
    final controller=TextEditingController();
    await showDialog<void>(context:context,builder:(ctx)=>AlertDialog(
      title:Text(t('النتائج المحفوظة والنسخ الاحتياطي','Saved results and backup')),
      content:SizedBox(width:400,child:SingleChildScrollView(child:Column(children:[
        ...history.map((e)=>Padding(padding:const EdgeInsets.only(bottom:12),child:SelectableText(e))),
        TextField(controller:controller,maxLines:3,decoration:InputDecoration(labelText:t('الصق نسخة JSON للاستعادة','Paste JSON backup to restore'))),
        Text(t('الاستعادة تستبدل سجل النتائج الحالي.','Restore replaces current result history.')),
      ]))),
      actions:[
        TextButton(onPressed:()=>Clipboard.setData(ClipboardData(text:jsonEncode(history))),child:Text(t('نسخ احتياطي','Copy backup'))),
        TextButton(onPressed:() async {try{await restoreHistory(controller.text);if(ctx.mounted)Navigator.pop(ctx);}catch(_){if(ctx.mounted)ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content:Text(t('نسخة غير صالحة أو تعذر الحفظ','Invalid backup or save failed'))));}},child:Text(t('استعادة','Restore'))),
        TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(t('إغلاق','Close'))),
      ]));
    controller.dispose();
  }
  final amount=TextEditingController(), rate=TextEditingController(), other=TextEditingController();
  final fourth=TextEditingController(), fifth=TextEditingController();
  bool fifo=true, prepaid=true;
  final lots=TextEditingController();
  String t(String ar,String en)=>widget.en?en:ar;
  @override void dispose(){amount.dispose();rate.dispose();other.dispose();fourth.dispose();fifth.dispose();lots.dispose();super.dispose();}
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
      [t("سداد أصل القرض","Repay loan principal"),t("القروض","Loans payable"),t("النقدية","Cash")],
      [t("دفع فوائد القرض","Pay loan interest"),t("مصروف الفوائد","Interest expense"),t("النقدية","Cash")],
      [t("استحقاق فوائد القرض","Accrue loan interest"),t("مصروف الفوائد","Interest expense"),t("فوائد مستحقة","Interest payable")],
      [t("سداد فوائد مستحقة","Pay accrued interest"),t("فوائد مستحقة","Interest payable"),t("النقدية","Cash")],
      [t("شراء مخزون نقدًا بالجرد المستمر","Cash inventory purchase"),t("المخزون","Inventory"),t("النقدية","Cash")],
      [t("رد مخزون للمورد قبل السداد","Return unpaid inventory"),t("الموردون","Payables"),t("المخزون","Inventory")],
      [t("إثبات تكلفة بضاعة مباعة بالجرد المستمر","Record cost of goods sold"),t("تكلفة المبيعات","Cost of sales"),t("المخزون","Inventory")],
      [t("إثبات انخفاض المخزون لصافي القيمة القابلة للتحقق","Inventory write-down to NRV"),t("خسارة انخفاض المخزون","Inventory write-down expense"),t("المخزون","Inventory")],
      [t("دفع أجور مستحقة","Pay accrued wages"),t("أجور مستحقة","Wages payable"),t("النقدية","Cash")],
      [t("دفع أجور الفترة","Pay current wages"),t("مصروف الأجور","Wages expense"),t("النقدية","Cash")],
      [t("إثبات إيراد خدمة مستحق","Accrue earned service revenue"),t("إيرادات مستحقة","Accrued revenue"),t("إيراد الخدمات","Service revenue")],
      [t("تحصيل إيراد مستحق","Collect accrued revenue"),t("النقدية","Cash"),t("إيرادات مستحقة","Accrued revenue")],
      [t("استحقاق الكهرباء","Accrue electricity"),t("مصروف الكهرباء","Electricity expense"),t("مصروفات مستحقة","Accrued expenses")],
      [t("سداد مصروف مستحق","Pay accrued expense"),t("مصروفات مستحقة","Accrued expenses"),t("النقدية","Cash")],
      [t("إيداع نقدية في البنك","Deposit cash into bank"),t("البنك","Bank"),t("الصندوق","Cash on hand")],
      [t("سحب نقدية من البنك للصندوق","Withdraw bank cash"),t("الصندوق","Cash on hand"),t("البنك","Bank")],
      [t("رسوم بنكية مخصومة","Bank fees deducted"),t("مصروف الرسوم البنكية","Bank fee expense"),t("البنك","Bank")],
      [t("إثبات خسائر ائتمانية متوقعة","Recognize expected credit loss"),t("خسائر ائتمانية","Credit loss expense"),t("مخصص خسائر ائتمانية","Loss allowance")],
      [t("شطب دين مغطى بالمخصص","Write off fully provided receivable"),t("مخصص خسائر ائتمانية","Loss allowance"),t("العملاء","Receivables")],
      [t("إطفاء أصل غير ملموس","Amortize intangible asset"),t("مصروف الإطفاء","Amortization expense"),t("مجمع الإطفاء","Accumulated amortization")],
      [t("دفع إيجار مقدم","Prepay rent"),t("إيجار مقدم","Prepaid rent"),t("النقدية","Cash")],
      [t("تسوية إيجار مقدم مستنفد","Recognize expired prepaid rent"),t("مصروف الإيجار","Rent expense"),t("إيجار مقدم","Prepaid rent")],
      [t("شراء أصل ثابت آجلًا","Credit equipment purchase"),t("الأصول الثابتة","Property and equipment"),t("دائنون","Other payables")],
      [t("إثبات مخصص مستوفٍ لشروط الاعتراف","Recognize qualifying provision"),t("مصروف المخصص","Provision expense"),t("المخصص","Provision")],
      [t("تسوية مخصص بالمبلغ المطابق","Settle provision at carrying amount"),t("المخصص","Provision"),t("النقدية","Cash")],
      [t("شراء مواد خام نقدًا","Cash raw materials purchase"),t("مواد خام","Raw materials"),t("النقدية","Cash")],
      [t("شراء مواد خام آجلًا","Credit raw materials purchase"),t("مواد خام","Raw materials"),t("الموردون","Payables")],
      [t("صرف مواد مباشرة للإنتاج","Issue direct materials"),t("إنتاج تحت التشغيل","Work in progress"),t("مواد خام","Raw materials")],
      [t("صرف مواد غير مباشرة للمصنع","Issue indirect materials"),t("تكاليف صناعية غير مباشرة","Manufacturing overhead"),t("مواد خام","Raw materials")],
      [t("تحميل أجور مباشرة مستحقة","Accrue direct labor"),t("إنتاج تحت التشغيل","Work in progress"),t("أجور مستحقة","Wages payable")],
      [t("تحميل أجور غير مباشرة مستحقة","Accrue indirect labor"),t("تكاليف صناعية غير مباشرة","Manufacturing overhead"),t("أجور مستحقة","Wages payable")],
      [t("تحميل التكاليف الصناعية على الإنتاج","Apply manufacturing overhead"),t("إنتاج تحت التشغيل","Work in progress"),t("تكاليف صناعية غير مباشرة محملة","Applied overhead")],
      [t("إتمام الإنتاج","Complete production"),t("إنتاج تام","Finished goods"),t("إنتاج تحت التشغيل","Work in progress")],
      [t("بيع إنتاج تام: إثبات التكلفة فقط","Finished goods sale: cost only"),t("تكلفة المبيعات","Cost of sales"),t("إنتاج تام","Finished goods")],
      [t("إثبات إهلاك معدات المصنع","Factory equipment depreciation"),t("تكاليف صناعية غير مباشرة","Manufacturing overhead"),t("مجمع الإهلاك","Accumulated depreciation")],
      [t("شراء أرض نقدًا","Cash land purchase"),t("الأراضي","Land"),t("النقدية","Cash")],
      [t("شراء أرض آجلًا","Credit land purchase"),t("الأراضي","Land"),t("دائنون","Other payables")],
      [t("تكلفة إنشاء أصل مؤهلة للرسملة نقدًا","Eligible construction cost paid"),t("أصول تحت الإنشاء","Construction in progress"),t("النقدية","Cash")],
      [t("تحويل أصل مكتمل جاهز للاستخدام","Transfer completed asset"),t("الأصول الثابتة","Property and equipment"),t("أصول تحت الإنشاء","Construction in progress")],
      [t("رسملة فوائد مؤهلة مستحقة","Accrue eligible borrowing costs"),t("أصول تحت الإنشاء","Construction in progress"),t("فوائد مستحقة","Interest payable")],
      [t("انخفاض قيمة أصل وفق نموذج التكلفة","Cost model asset impairment"),t("خسارة انخفاض القيمة","Impairment loss"),t("مجمع انخفاض القيمة","Accumulated impairment")],
      [t("عكس انخفاض أصل ضمن الحدود المسموحة","Permitted impairment reversal"),t("مجمع انخفاض القيمة","Accumulated impairment"),t("عكس خسارة انخفاض القيمة","Impairment reversal")],
      [t("شراء برنامج مؤهل كأصل نقدًا","Qualifying software purchase"),t("برامج حاسوبية","Software"),t("النقدية","Cash")],
      [t("دفع تكاليف بحث","Pay research costs"),t("مصروف البحث","Research expense"),t("النقدية","Cash")],
      [t("دفع تكاليف تطوير مستوفية لشروط الرسملة","Pay qualifying development costs"),t("أصل تطوير","Development asset"),t("النقدية","Cash")],
      [t("إثبات توزيعات أرباح مستحقة بعد اعتمادها","Recognize authorized dividends"),t("أرباح محتجزة","Retained earnings"),t("توزيعات مستحقة","Dividends payable")],
      [t("سداد توزيعات أرباح مستحقة","Pay dividends payable"),t("توزيعات مستحقة","Dividends payable"),t("النقدية","Cash")],
      [t("مسحوبات نقدية لمنشأة فردية","Sole proprietor cash drawings"),t("مسحوبات شخصية","Drawings"),t("النقدية","Cash")],
      [t("إقفال المسحوبات في رأس المال","Close drawings to capital"),t("رأس المال","Capital"),t("مسحوبات شخصية","Drawings")],
      [t("شراء أسهم خزينة نقدًا","Purchase treasury shares"),t("أسهم خزينة","Treasury shares"),t("النقدية","Cash")],
      [t("تحويل أرباح محتجزة لاحتياطي معتمد","Transfer retained earnings to reserve"),t("أرباح محتجزة","Retained earnings"),t("احتياطي","Reserve")],
      [t("إثبات ضريبة دخل جارية مستحقة","Accrue current income tax"),t("مصروف ضريبة الدخل","Income tax expense"),t("ضريبة دخل مستحقة","Income tax payable")],
      [t("سداد ضريبة دخل مستحقة","Pay income tax payable"),t("ضريبة دخل مستحقة","Income tax payable"),t("النقدية","Cash")],
      [t("دفع ضريبة دخل مقدمة قابلة للتسوية","Pay income tax advance"),t("ضريبة دخل مدفوعة مقدمًا","Income tax prepayment"),t("النقدية","Cash")],
      [t("إثبات أصل ضريبي مؤجل مؤهل عبر الربح أو الخسارة","Recognize qualifying deferred tax asset in profit or loss"),t("أصل ضريبي مؤجل","Deferred tax asset"),t("إيراد ضريبي مؤجل","Deferred tax benefit")],
      [t("إثبات التزام ضريبي مؤجل عبر الربح أو الخسارة","Recognize deferred tax liability in profit or loss"),t("مصروف ضريبي مؤجل","Deferred tax expense"),t("التزام ضريبي مؤجل","Deferred tax liability")],
      [t("سداد ضريبة قيمة مضافة مستحقة","Pay VAT payable"),t("ضريبة قيمة مضافة مستحقة","VAT payable"),t("النقدية","Cash")],
      [t("استرداد ضريبة مدخلات مستحقة","Receive input tax refund"),t("النقدية","Cash"),t("ضريبة مدخلات قابلة للاسترداد","Recoverable input tax")],
      [t("دفع تأمين ضمان قابل للاسترداد","Pay refundable deposit"),t("تأمينات لدى الغير","Refundable deposits"),t("النقدية","Cash")],
      [t("استرداد تأمين ضمان","Recover deposit"),t("النقدية","Cash"),t("تأمينات لدى الغير","Refundable deposits")],
      [t("استلام تأمين ضمان واجب الرد","Receive refundable deposit"),t("النقدية","Cash"),t("تأمينات للغير","Refundable deposits payable")],
      [t("رد تأمين ضمان للغير","Return refundable deposit"),t("تأمينات للغير","Refundable deposits payable"),t("النقدية","Cash")],
      [t("دفع دفعة مقدمة لمورد","Advance to supplier"),t("دفعات مقدمة للموردين","Supplier advances"),t("النقدية","Cash")],
      [t("تسوية دفعة مورد مقابل فاتورة مثبتة","Apply supplier advance"),t("الموردون","Payables"),t("دفعات مقدمة للموردين","Supplier advances")],
      [t("رد دفعة عميل قبل تقديم الخدمة","Refund customer advance"),t("إيراد مؤجل","Deferred revenue"),t("النقدية","Cash")],
      [t("إثبات فوائد مكتسبة مستحقة","Accrue interest income"),t("فوائد مستحقة القبض","Interest receivable"),t("إيراد الفوائد","Interest income")],
      [t("تحصيل فوائد مستحقة القبض","Collect interest receivable"),t("النقدية","Cash"),t("فوائد مستحقة القبض","Interest receivable")],
      [t("إثبات توزيعات مستحقة القبض عند نشوء الحق","Recognize dividend receivable"),t("توزيعات مستحقة القبض","Dividend receivable"),t("إيراد توزيعات","Dividend income")],
      [t("تحصيل توزيعات مستحقة القبض","Collect dividend receivable"),t("النقدية","Cash"),t("توزيعات مستحقة القبض","Dividend receivable")],
      [t("خسارة عملة على ذمة مدينة نقدية","FX loss on monetary receivable"),t("خسارة فروق عملة","FX loss"),t("العملاء","Receivables")],
      [t("ربح عملة على ذمة مدينة نقدية","FX gain on monetary receivable"),t("العملاء","Receivables"),t("ربح فروق عملة","FX gain")],
      [t("خسارة عملة على ذمة دائنة نقدية","FX loss on monetary payable"),t("خسارة فروق عملة","FX loss"),t("الموردون","Payables")],
      [t("ربح عملة على ذمة دائنة نقدية","FX gain on monetary payable"),t("الموردون","Payables"),t("ربح فروق عملة","FX gain")],
      [t("عكس مخصص لم يعد مطلوبًا","Reverse no longer required provision"),t("المخصص","Provision"),t("عكس مصروف المخصص","Provision reversal")],
      [t("عكس خسارة ائتمانية متوقعة","Reverse expected credit loss"),t("مخصص خسائر ائتمانية","Loss allowance"),t("عكس خسائر ائتمانية","Credit loss reversal")],
      [t("عكس انخفاض المخزون ضمن الخسارة السابقة","Reverse inventory write-down within original loss"),t("المخزون","Inventory"),t("عكس انخفاض المخزون","Inventory write-down reversal")],
      [t("شراء بضاعة نقدًا بالجرد الدوري","Periodic cash merchandise purchase"),t("المشتريات","Purchases"),t("النقدية","Cash")],
      [t("شراء بضاعة آجلًا بالجرد الدوري","Periodic credit merchandise purchase"),t("المشتريات","Purchases"),t("الموردون","Payables")],
      [t("رد مشتريات آجلة بالجرد الدوري","Periodic credit purchase return"),t("الموردون","Payables"),t("مردودات المشتريات","Purchase returns")],
      [t("نقل مشتريات مدفوع بالجرد الدوري","Periodic freight in paid"),t("نقل المشتريات","Freight in"),t("النقدية","Cash")],
      [t("بيع بضاعة نقدًا دون الضريبة: الإيراد فقط","Cash goods sale: revenue only"),t("النقدية","Cash"),t("إيراد المبيعات","Sales revenue")],
      [t("بيع بضاعة آجلًا دون الضريبة: الإيراد فقط","Credit goods sale: revenue only"),t("العملاء","Receivables"),t("إيراد المبيعات","Sales revenue")],
      [t("رد مبيعات آجلة: الإيراد فقط","Credit sales return: revenue only"),t("مردودات المبيعات","Sales returns"),t("العملاء","Receivables")],
      [t("إعادة بضاعة مرتجعة صالحة للمخزون بالتكلفة","Restore saleable returned goods at cost"),t("المخزون","Inventory"),t("تكلفة المبيعات","Cost of sales")],
      [t("إثبات عجز مخزون مؤكد غير قابل للاسترداد","Recognize confirmed inventory shortage"),t("خسارة عجز المخزون","Inventory shortage loss"),t("المخزون","Inventory")],
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
    if(mode==3){
      final d=read(fourth), sold=read(fifth);
      if(a!=null&&b!=null&&c!=null&&d!=null&&sold!=null&&a+c>0&&sold<=a+c){
        final total=a*b+c*d;
        final first=sold<a?sold:a;
        final cost=fifo?first*b+(sold-first)*d:sold*total/(a+c);
        if(total.isFinite&&cost.isFinite){
          result='${t("تكلفة البضاعة المباعة","Cost of goods sold")}: ${cost.toStringAsFixed(2)}\n${t("مخزون آخر المدة","Ending inventory")}: ${(total-cost).toStringAsFixed(2)}\n${t("الكمية المتبقية","Remaining units")}: ${(a+c-sold).toStringAsFixed(2)}';
        }
      }
    }
    if(mode==4&&a!=null&&b!=null&&b>0&&c!=null&&c<=b){
      final used=a*(c/b);
      final debit=prepaid?t('مصروف الفترة','Period expense'):t('إيراد مؤجل','Deferred revenue');
      final credit=prepaid?t('مصروف مقدم','Prepaid expense'):t('إيراد الفترة','Period revenue');
      result='${t("المبلغ المعترف به","Recognized amount")}: ${used.toStringAsFixed(2)}\n${t("الرصيد المتبقي","Remaining balance")}: ${(a-used).toStringAsFixed(2)}\n${t("مدين","Debit")}: $debit — ${used.toStringAsFixed(2)}\n${t("دائن","Credit")}: $credit — ${used.toStringAsFixed(2)}';
    }
    if(mode==5&&a!=null&&b!=null&&c!=null){
      final cost=b+c;
      if(cost.isFinite){
        final profit=a-cost;
        result='${t("إجمالي تكلفة المشروع","Total project cost")}: ${cost.toStringAsFixed(2)}\n${t("ربح أو خسارة المشروع","Project profit or loss")}: ${profit.toStringAsFixed(2)}\n${t("هامش الربح","Profit margin")}: ${a>0?(profit/a*100).toStringAsFixed(2)+"%":t("غير معرف","Undefined")}';
      }
    }
    if(mode==6&&a!=null&&b!=null&&c!=null){
      final equity=a-b;
      result='${t("حقوق الملكية المستنتجة","Implied equity")}: ${equity.toStringAsFixed(2)}\n${t("فرق المعادلة المحاسبية","Accounting equation difference")}: ${(equity-c).toStringAsFixed(2)}\n${a>0?t("نسبة الالتزامات للأصول","Liabilities to assets")+": "+(b/a*100).toStringAsFixed(2)+"%":t("النسبة غير معرفة","Ratio undefined")}\n${equity<0?t("تنبيه: الالتزامات تتجاوز الأصول","Warning: liabilities exceed assets"):t("التقييم يحتاج مقارنة تاريخية وقطاعية","Assessment requires historical and industry comparison")}';
    }
    if(mode==7&&a!=null&&b!=null&&c!=null){
      final gross=a+b;
      if(gross.isFinite&&c<=gross){
        result='${t("مدين: الأصل أو المصروف","Debit: asset or expense")}: ${a.toStringAsFixed(2)}\n${t("مدين: ضريبة مدخلات قابلة للاسترداد","Debit: recoverable input tax")}: ${b.toStringAsFixed(2)}\n${t("دائن: النقدية","Credit: cash")}: ${c.toStringAsFixed(2)}\n${t("دائن: الموردون","Credit: payables")}: ${(gross-c).toStringAsFixed(2)}';
      }
    }
    if(mode==8&&a!=null){
      final rows=lots.text.trim().split('\n');
      double quantity=0,total=0,cost=0,remaining=a;
      bool valid=lots.text.trim().isNotEmpty;
      for(final row in rows){
        final parts=row.trim().split(';');
        if(parts.length!=2){valid=false;break;}
        final q=double.tryParse(parts[0].trim()),p=double.tryParse(parts[1].trim());
        if(q==null||p==null||!q.isFinite||!p.isFinite||q<=0||p<0){valid=false;break;}
        quantity+=q;total+=q*p;
        final used=remaining<q?remaining:q;
        cost+=used*p;remaining-=used;
      }
      if(valid&&quantity.isFinite&&total.isFinite&&a<=quantity&&quantity>0){
        if(!fifo)cost=a/quantity*total;
        result='${t("تكلفة المبيعات","Cost of sales")}: ${cost.toStringAsFixed(2)}\n${t("المخزون المتبقي","Ending inventory")}: ${(total-cost).toStringAsFixed(2)}\n${t("الكمية المتبقية","Remaining quantity")}: ${(quantity-a).toStringAsFixed(2)}';
      }
    }
    if(mode==9&&a!=null&&b!=null&&c!=null&&fourth.text.isNotEmpty){
      final cost=read(fourth),gross=a+b;
      if(cost!=null&&gross.isFinite&&c<=gross){
        result='${t("مدين: النقدية","Debit: cash")}: ${c.toStringAsFixed(2)}\n${t("مدين: العملاء","Debit: receivables")}: ${(gross-c).toStringAsFixed(2)}\n${t("دائن: المبيعات","Credit: sales")}: ${a.toStringAsFixed(2)}\n${t("دائن: ضريبة المخرجات","Credit: output tax")}: ${b.toStringAsFixed(2)}\n\n${t("مدين: تكلفة المبيعات","Debit: cost of sales")}: ${cost.toStringAsFixed(2)}\n${t("دائن: المخزون","Credit: inventory")}: ${cost.toStringAsFixed(2)}';
      }
    }
    if(mode==10&&a!=null&&b!=null&&a>=b){
      final diff=a-b;
      result='${t("التسوية الإضافية","Additional adjustment")}: ${diff.toStringAsFixed(2)}\n${t("مدين","Debit")}: ${prepaid?t("مصروف الفترة","Period expense"):t("إيرادات مستحقة","Accrued revenue")} — ${diff.toStringAsFixed(2)}\n${t("دائن","Credit")}: ${prepaid?t("مصروفات مستحقة","Accrued expenses"):t("إيراد الفترة","Period revenue")} — ${diff.toStringAsFixed(2)}';
    }
    Widget field(TextEditingController ctrl,String label)=>Padding(padding:const EdgeInsets.only(bottom:12),child:TextField(controller:ctrl,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:label),onChanged:(_)=>setState((){})));
    return ListView(padding:const EdgeInsets.all(12),children:[
      OutlinedButton.icon(onPressed:showHistory,icon:const Icon(Icons.history),label:Text(t('النتائج المحفوظة','Saved results'))),
      Wrap(spacing:8,runSpacing:8,children:List.generate(11,(i)=>ChoiceChip(label:Text([t('القيود الذكية','Smart entries'),t('التسعير','Pricing'),t('فحص التوازن','Balance check'),t('المخزون','Inventory'),t('التسويات','Adjustments'),t('تكاليف المشاريع','Project costs'),t('تشخيص مالي','Financial check'),t('قيد شراء مركب','Compound purchase'),t('مخزون متعدد','Multiple lots'),t('بيع مركب','Compound sale'),t('تسوية مستحقات','Accrual adjustment')][i]),selected:mode==i,onSelected:(_)=>setState((){mode=i;amount.clear();rate.clear();other.clear();fourth.clear();fifth.clear();lots.clear();})))),
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
      if(mode==3)...[
        SwitchListTile(title:Text(fifo?'FIFO':t('المتوسط المرجح الدوري','Periodic weighted average')),value:fifo,onChanged:(v)=>setState(()=>fifo=v)),
        field(amount,t('كمية الدفعة الأولى','First lot quantity')),
        field(rate,t('تكلفة وحدة الدفعة الأولى','First lot unit cost')),
        field(other,t('كمية الدفعة الثانية','Second lot quantity')),
        field(fourth,t('تكلفة وحدة الدفعة الثانية','Second lot unit cost')),
        field(fifth,t('الكمية المباعة','Units sold')),
        Text(t('دفعتان متاحتان قبل البيع؛ لا تتجاوز الكمية المباعة إجمالي الكمية.','Two lots available before sale; sold units must not exceed available units.')),
      ],
      if(mode==4)...[
        SwitchListTile(title:Text(prepaid?t('مصروف مدفوع مقدمًا','Prepaid expense'):t('إيراد مؤجل','Deferred revenue')),value:prepaid,onChanged:(v)=>setState(()=>prepaid=v)),
        field(amount,t('المبلغ الإجمالي المدفوع أو المقبوض مقدمًا','Total advance amount')),
        field(rate,t('إجمالي مدة التغطية','Total coverage duration')),
        field(other,t('المدة المستنفدة','Elapsed duration')),
        Text(t('استخدم وحدة زمنية واحدة؛ يفترض الاعتراف بالتساوي على المدة. القيد يفترض عدم تسجيل تسويات سابقة.','Use the same time unit; assumes straight-line recognition and no prior adjustments.')),
      ],
      if(mode==5)...[field(amount,t('إيرادات المشروع','Project revenue')),field(rate,t('التكاليف المباشرة','Direct costs')),field(other,t('التكاليف غير المباشرة المخصصة','Allocated indirect costs'))],
      if(mode==6)...[field(amount,t('إجمالي الأصول','Total assets')),field(rate,t('إجمالي الالتزامات','Total liabilities')),field(other,t('حقوق الملكية المسجلة (غير سالبة)','Recorded equity (nonnegative)'))],
      if(mode==7)...[field(amount,t('قيمة الشراء قبل الضريبة','Purchase before tax')),field(rate,t('ضريبة قابلة للاسترداد','Recoverable tax amount')),field(other,t('المدفوع نقدًا','Cash paid')),Text(t('يفترض قابلية استرداد الضريبة بالكامل.','Assumes fully recoverable input tax.'))],
      if(mode==8)...[SwitchListTile(title:Text(fifo?'FIFO':t('المتوسط المرجح الدوري','Periodic weighted average')),value:fifo,onChanged:(v)=>setState(()=>fifo=v)),TextField(controller:lots,maxLines:5,onChanged:(_)=>setState((){}),decoration:InputDecoration(labelText:t('كل دفعة في سطر: الكمية;تكلفة الوحدة','One lot per line: quantity;unit cost'),hintText:'10;5\n20;6')),const SizedBox(height:12),field(amount,t('الكمية المباعة','Units sold'))],
      if(mode==9)...[field(amount,t('المبيعات قبل الضريبة','Sales before tax')),field(rate,t('ضريبة المخرجات','Output tax')),field(other,t('المقبوض نقدًا','Cash received')),field(fourth,t('تكلفة البضاعة المباعة','Cost of goods sold')),Text(t('بيع بضاعة بالجرد المستمر مع تحقق شروط الاعتراف بالإيراد.','Perpetual inventory sale meeting revenue recognition criteria.'))],
      if(mode==10)...[SwitchListTile(title:Text(prepaid?t('مصروف مستحق','Accrued expense'):t('إيراد مستحق','Accrued revenue')),value:prepaid,onChanged:(v)=>setState(()=>prepaid=v)),field(amount,t('إجمالي الاستحقاق المطلوب','Required total accrual')),field(rate,t('الاستحقاق المثبت سابقًا','Previously recorded accrual')),Text(t('لزيادة الاستحقاق فقط؛ لا تشمل عكس الاستحقاق الزائد.','For increasing accruals only; excludes reversal of excess accrual.'))],
      if(result==null && amount.text.trim().isNotEmpty) Padding(padding:const EdgeInsets.all(8),child:Text(t('أكمل المدخلات وتحقق من الحدود الموضحة.','Complete the inputs and check the stated limits.'))),
      if(result!=null)Card(color:const Color(0xffe5f5ef),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[SelectableText(result,style:const TextStyle(fontSize:17)),Wrap(children:[TextButton(onPressed:()=>exportResult(result!,true),child:const Text('PDF')),TextButton(onPressed:()=>exportResult(result!,false),child:const Text('Excel'))]),TextButton.icon(onPressed:() async {try{await saveResult(result!);if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t('تم الحفظ','Saved'))));}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t('تعذر الحفظ','Save failed'))));}},icon:const Icon(Icons.save),label:Text(t('حفظ النتيجة','Save result'))),TextButton.icon(onPressed:()=>Clipboard.setData(ClipboardData(text:result!)),icon:const Icon(Icons.copy),label:Text(t('نسخ النتيجة','Copy result')))]))),
    ]);
  }
}
