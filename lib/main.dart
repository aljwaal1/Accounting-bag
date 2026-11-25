import 'package:shared_preferences/shared_preferences.dart';
import 'number_input.dart';
import 'feasibility.dart';
import 'smart_tools.dart';
import 'comprehensive_ratios.dart';
import 'accounting_metrics.dart';
import 'finance_tools.dart';
import 'package:flutter/material.dart';
void main() => runApp(const AccountingBag());
class AccountingBag extends StatefulWidget {
  const AccountingBag({super.key});
  @override State<AccountingBag> createState() => _AppState();
}
class _AppState extends State<AccountingBag> {
  bool en = false;
  int tab = 0;
  bool dark=false;
  final favorites=<int>{};
  String query='';
  bool onlyFavorites=false;
  bool expandedTools=false;
  @override void initState(){super.initState();loadSettings();}
  Future<void> loadSettings() async {
    try {
      final p=await SharedPreferences.getInstance();
      if(!mounted)return;
      setState((){
        dark=p.getBool('bag_dark')??false;
        en=p.getBool('bag_english')??false;
        favorites.addAll((p.getStringList('bag_favorites')??[]).map(int.tryParse).whereType<int>().where((i)=>i>=0&&i<10));
      });
    }catch(_){ /* defaults remain available */ }
  }
  Future<void> saveSettings() async {
    try {
      final p=await SharedPreferences.getInstance();
      await p.setBool('bag_dark',dark);
      await p.setBool('bag_english',en);
      await p.setStringList('bag_favorites',favorites.map((i)=>i.toString()).toList());
    }catch(_){ /* settings remain usable for this session */ }
  }
  String tr(String ar, String eng) => en ? eng : ar;
  @override Widget build(BuildContext context) {
    final names = [tr('الحاسبات','Calculators'),tr('الفوائد والتمويل','Interest & Finance'),tr('الإهلاك والإطفاء','Depreciation'),tr('النسب المالية','Financial Ratios'),tr('دراسة الجدوى','Feasibility'),tr('الاختبارات','Quizzes'),tr('الملخصات','Summaries'),tr('القيود','Entries'),tr('النماذج','Templates'),tr('أدوات ذكية','Smart tools')];
    final icons = [Icons.calculate,Icons.account_balance,Icons.trending_down,Icons.pie_chart,Icons.assessment,Icons.quiz,Icons.menu_book,Icons.receipt_long,Icons.description,Icons.auto_awesome];
    const palette=<Color>[
      Color(0xff1479c9),Color(0xff7b55cc),Color(0xffe58a27),
      Color(0xff159b86),Color(0xffd85a87),Color(0xff6b78d8),
      Color(0xff229baf),Color(0xffbd7042),Color(0xff577db0),Color(0xff087e87),
    ];
    final scheme=ColorScheme.fromSeed(seedColor:const Color(0xff3568c9),brightness:Brightness.light);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3:true,
        colorScheme:scheme,
        scaffoldBackgroundColor:const Color(0xfff4f7ff),
        appBarTheme:const AppBarTheme(backgroundColor:Color(0xffedf2ff),foregroundColor:Color(0xff203660),centerTitle:true,elevation:0),
        cardTheme:CardThemeData(color:Colors.white,elevation:1,shadowColor:const Color(0x183668aa),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18))),
        inputDecorationTheme:InputDecorationTheme(
          filled:true,fillColor:Colors.white,
          border:OutlineInputBorder(borderRadius:BorderRadius.circular(14)),
          enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:Color(0xffccd9ed))),
          focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:Color(0xff3568c9),width:2)),
        ),
        filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:const Color(0xff3568c9),foregroundColor:Colors.white,padding:const EdgeInsets.symmetric(vertical:14,horizontal:18))),
      ),
      darkTheme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff3568c9),brightness:Brightness.dark)),
      themeMode:dark?ThemeMode.dark:ThemeMode.light,
      home: Directionality(textDirection: en ? TextDirection.ltr : TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text(tr('الحقيبة المحاسبية','Accounting Bag')),actions: [
            IconButton(tooltip:tr('الوضع الليلي','Dark mode'),onPressed:(){setState(()=>dark=!dark);saveSettings();},icon:Icon(dark?Icons.light_mode:Icons.dark_mode)),
            TextButton(onPressed: () {setState(() => en = !en);saveSettings();}, child: Text(en ? 'العربية' : 'English'))
          ]),
          body: LayoutBuilder(builder:(context,constraints)=>Column(children: [
            if(constraints.maxHeight>480) Container(width: double.infinity,margin: const EdgeInsets.all(12),padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient:const LinearGradient(colors:[Color(0xff2364c9),Color(0xff18a5a1)]),borderRadius: BorderRadius.circular(18)),
              child: Text(tr('تعلم واحسب وراجع حساباتك — دون إنترنت','Learn, calculate and review — offline'),
                style: const TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold))),
            Padding(padding:const EdgeInsets.symmetric(horizontal:12),child:Row(children:[
              Expanded(child:TextField(decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:tr('ابحث عن قسم','Search sections'),isDense:true),onChanged:(v)=>setState(()=>query=v))),
              IconButton(tooltip:tr('المفضلة','Favorites'),onPressed:()=>setState(()=>onlyFavorites=!onlyFavorites),icon:Icon(onlyFavorites?Icons.star:Icons.star_border)),
              IconButton(tooltip:tr('عرض الأقسام','Show sections'),onPressed:()=>setState(()=>expandedTools=!expandedTools),icon:Icon(expandedTools?Icons.view_agenda:Icons.grid_view)),
            ])),
            SizedBox(height:expandedTools&&constraints.maxHeight>480?180:88,child:GridView.count(crossAxisCount:expandedTools&&constraints.maxHeight>480?3:1,scrollDirection:expandedTools&&constraints.maxHeight>480?Axis.vertical:Axis.horizontal,childAspectRatio:expandedTools&&constraints.maxHeight>480?2.2:0.8,padding:const EdgeInsets.all(6),children:[
              for(var i=0;i<names.length;i++)if(names[i].toLowerCase().contains(query.toLowerCase())&&(!onlyFavorites||favorites.contains(i)))
                Padding(padding:const EdgeInsets.all(3),child:Material(color:tab==i?palette[i]:palette[i].withValues(alpha:0.16),borderRadius:BorderRadius.circular(12),child:InkWell(onTap:()=>setState(()=>tab=i),onLongPress:(){setState(()=>favorites.contains(i)?favorites.remove(i):favorites.add(i));saveSettings();},child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(favorites.contains(i)?Icons.star:icons[i],color:tab==i?Colors.white:palette[i]),Flexible(child:Text(names[i],textAlign:TextAlign.center,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:11,color:tab==i?Colors.white:null)))])))),
            ])),
            Expanded(child: IndexedStack(index: tab,children: [
              CalculatorScreen(key: ValueKey('calc'+en.toString()),en: en),
              FinanceToolsScreen(key: ValueKey('finance'+en.toString()),en: en),
              AccountingMetricsScreen(key: ValueKey('depreciation'+en.toString()),en: en,depreciation: true),
              FinancialRatioModes(en: en),
              FeasibilityScreen(key: ValueKey('feasibility'+en.toString()),en: en),
              QuizScreen(key: ValueKey('quiz'+en.toString()),en: en),
              NotesScreen(en: en,entries: false),
              NotesScreen(en: en,entries: true),
              TemplatesScreen(en: en),
              SmartTools(en: en)
            ]))
          ])),
        )),
    );
  }
}
Widget card(String title, Widget child) => Card(margin: const EdgeInsets.symmetric(horizontal: 12,vertical: 7),
 child: Padding(padding: const EdgeInsets.all(16),child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,children: [
 Text(title,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),const SizedBox(height: 12),child])));
String fmt(double n) {
 final parts = n.toStringAsFixed(2).split('.');
 final integer = parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'),(m) => ',');
 return integer+'.'+parts.last;
}
class CalculatorScreen extends StatefulWidget {
 final bool en;
 const CalculatorScreen({super.key,required this.en});
 @override State<CalculatorScreen> createState() => _CalculatorState();
}
class _CalculatorState extends State<CalculatorScreen> {
 final a=TextEditingController(),b=TextEditingController(),c=TextEditingController();
 int mode=0;
 String? output;
 String tr(String ar,String en)=>widget.en?en:ar;
 @override void dispose(){a.dispose();b.dispose();c.dispose();super.dispose();}
 void compute(){
 final x=parseAccountingNumber(a.text);
 final y=parseAccountingNumber(b.text);
 final z=parseAccountingNumber(c.text);
 if(x==null || y==null || (mode!=1 && z==null)){
  setState(()=>output=tr('أدخل قيمًا رقمية صحيحة','Enter valid numeric values'));return;
 }
 double? result;
 if(mode==0 && z!>0 && x>=y && y>=0 && x.isFinite && y.isFinite && z.isFinite) result=(x-y)/z;
 if(mode==1 && y>0 && x>=0 && x.isFinite && y.isFinite) result=(x-y)/y*100;
 if(mode==2 && y>z! && x>=0 && z>=0 && x.isFinite && y.isFinite && z.isFinite) result=x/(y-z);
 if(mode==3 && z!>0 && x>=y && y>=0 && x.isFinite && y.isFinite && z.isFinite) result=(x-y)/z;
 setState(()=>output=result==null || !result.isFinite
  ? tr('تحقق من المدخلات والمقام','Check inputs and denominators')
  : tr('النتيجة: ','Result: ')+fmt(result)+(mode==1?'%':''));
 }
 @override Widget build(BuildContext context){
 final names=[tr('الإهلاك بالقسط الثابت','Straight-line depreciation'),tr('نسبة الربح على التكلفة','Markup on cost'),tr('نقطة التعادل بالوحدات','Break-even units'),tr('نسبة السيولة السريعة','Quick ratio')];
 final labels=[
 [tr('تكلفة الأصل','Asset cost'),tr('القيمة المتبقية','Residual value'),tr('العمر الإنتاجي بالسنوات','Useful life in years')],
 [tr('سعر البيع','Selling price'),tr('التكلفة','Cost')],
 [tr('التكاليف الثابتة','Fixed costs'),tr('سعر بيع الوحدة','Unit price'),tr('التكلفة المتغيرة للوحدة','Variable cost per unit')],
 [tr('الأصول المتداولة','Current assets'),tr('المخزون','Inventory'),tr('الالتزامات المتداولة','Current liabilities')]
 ];
 final ctrls=[a,b,c];
 return ListView(children:[
 card(tr('اختر الحاسبة','Choose calculator'),DropdownButtonFormField<int>(initialValue: mode,isExpanded:true,
 items: List.generate(names.length,(i)=>DropdownMenuItem(value:i,child:Text(names[i],overflow: TextOverflow.ellipsis))),
 onChanged:(v)=>setState((){mode=v??0;output=null;for(final ctrl in ctrls){ctrl.clear();}}))),
 card(names[mode],Column(children:[
 for(int i=0;i<labels[mode].length;i++) Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:ctrls[i],
 keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),
 decoration:InputDecoration(labelText:labels[mode][i],border:const OutlineInputBorder()))),
 SizedBox(width:double.infinity,child:FilledButton(onPressed:compute,child:Text(tr('احسب','Calculate')))),
 if(output!=null) Padding(padding:const EdgeInsets.only(top:12),child:SelectableText(output!,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)))
 ])),
 Padding(padding:const EdgeInsets.all(15),child:Text(tr('الحاسبات تعليمية. قد تحتاج وحدات نقطة التعادل إلى التقريب للأعلى.','Educational calculations; break-even units may require rounding up.')))
 ]);
 }
}
class QuizScreen extends StatefulWidget {
 final bool en;
 const QuizScreen({super.key,required this.en});
 @override State<QuizScreen> createState()=>_QuizState();
}
class _QuizState extends State<QuizScreen>{
 int index=0,score=0;
 int? choice;
 final questions=const [
 ['طبيعة حساب الأصول؟','Normal asset balance?','مدين','دائن','Debit','Credit','0'],
 ['القيد عند تحصيل حساب عميل؟','Entry on collecting a receivable?','مدين نقدية، دائن عملاء','مدين عملاء، دائن نقدية','Debit cash, credit receivables','Debit receivables, credit cash','0'],
 ['شراء معدات نقدًا يؤدي إلى؟','Buying equipment for cash causes?','زيادة إجمالي الأصول','تبادل بين الأصول','Increase total assets','Exchange between assets','1'],
 ['المعادلة المحاسبية الصحيحة؟','Correct accounting equation?','الأصول = الالتزامات + حقوق الملكية','الأصول = المصروفات + الإيرادات','Assets = Liabilities + Equity','Assets = Expenses + Revenue','0'],
 ];
 String tr(String ar,String en)=>widget.en?en:ar;
 @override Widget build(BuildContext context){
 if(index>=questions.length)return ListView(children:[card(tr('النتيجة','Result'),Column(children:[
 Text(score.toString()+' / '+questions.length.toString(),style:const TextStyle(fontSize:32)),
 FilledButton(onPressed:()=>setState((){index=0;score=0;choice=null;}),child:Text(tr('أعد الاختبار','Restart')))
 ]))]);
 final q=questions[index]; final correct=int.parse(q[6]);
 return ListView(children:[card(tr('السؤال','Question')+' '+(index+1).toString()+' / '+questions.length.toString(),Column(children:[
 LinearProgressIndicator(value:(index+1)/questions.length),
 const SizedBox(height:16),Text(widget.en?q[1]:q[0],style:const TextStyle(fontSize:18)),
 for(int i=0;i<2;i++) Padding(padding: const EdgeInsets.symmetric(vertical:4),child: OutlinedButton.icon(onPressed:()=>setState(()=>choice=i),icon:Icon(choice==i?Icons.radio_button_checked:Icons.radio_button_unchecked),label:Align(alignment:AlignmentDirectional.centerStart,child:Text(q[widget.en?i+4:i+2])))),
 FilledButton(onPressed:choice==null?null:()=>setState((){if(choice==correct)score++;index++;choice=null;}),child:Text(tr('التالي','Next')))
 ]))]);
 }
}
class NotesScreen extends StatelessWidget{
 final bool en,entries;
 const NotesScreen({super.key,required this.en,required this.entries});
 @override Widget build(BuildContext context){
 const notes=[
 ['المعادلة المحاسبية','Accounting equation','الأصول = الالتزامات + حقوق الملكية.','Assets = Liabilities + Equity.'],
 ['القيد المزدوج','Double-entry','لكل عملية مجموع مبالغ مدينة يساوي مجموع المبالغ الدائنة.','Every transaction has equal total debits and credits.'],
 ['أساس الاستحقاق','Accrual basis','تعترف المنشأة بالإيراد عند اكتسابه والمصروف عند تكبده.','Recognize revenue when earned and expenses when incurred.'],
 ['مجمل الربح','Gross profit','صافي المبيعات ناقص تكلفة المبيعات.','Net sales minus cost of sales.'],
 ['رأس المال العامل','Working capital','الأصول المتداولة ناقص الالتزامات المتداولة.','Current assets minus current liabilities.']
 ];
 const journals=[
 ['شراء مخزون نقدًا','Cash inventory purchase','المخزون','Inventory','النقدية','Cash','وفق نظام الجرد المستمر','Under the perpetual inventory system'],
 ['تحصيل دين من عميل','Collect receivable','النقدية','Cash','الذمم المدينة','Accounts receivable','لا ينشأ إيراد جديد من التحصيل','Collection does not create new revenue'],
 ['دفع إيجار الفترة','Pay current rent','مصروف الإيجار','Rent expense','النقدية','Cash','إثبات مصروف الإيجار المدفوع للفترة','Record current-period rent expense paid'],
 ['شراء معدات بالآجل','Equipment on account','المعدات','Equipment','الذمم الدائنة','Accounts payable','إثبات أصل والتزام','Record an asset and liability'],
 ['إثبات الرواتب المستحقة','Accrue salaries','مصروف الرواتب','Salaries expense','رواتب مستحقة الدفع','Salaries payable','رواتب الفترة غير المدفوعة','Unpaid salaries for the period']
 ];
 return ListView(children: [
 if(!entries)for(final n in notes)card(en?n[1]:n[0],Text(en?n[3]:n[2])),
 if(entries)for(final j in journals)card(en?j[1]:j[0],Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 Text((en?'Debit: ':'مدين: ')+(en?j[3]:j[2]),style:const TextStyle(fontWeight:FontWeight.bold)),
 Text((en?'Credit: ':'دائن: ')+(en?j[5]:j[4]),style:const TextStyle(fontWeight:FontWeight.bold)),
 const SizedBox(height:8),Text(en?j[7]:j[6])
 ]))
 ]);
 }
}
class TemplatesScreen extends StatelessWidget{
 final bool en;
 const TemplatesScreen({super.key,required this.en});
 @override Widget build(BuildContext context)=>ListView(children:[
 card(en?'Journal voucher':'نموذج قيد يومية',Text(en?'Date | Account | Debit | Credit | Description':'التاريخ | الحساب | مدين | دائن | البيان')),
 card(en?'Trial balance':'ميزان المراجعة',Text(en?'Account | Debit balance | Credit balance':'الحساب | الرصيد المدين | الرصيد الدائن')),
 card(en?'Income statement':'قائمة الدخل',Text(en?'Net sales − Cost of sales = Gross profit':'صافي المبيعات − تكلفة المبيعات = مجمل الربح')),
 Padding(padding:const EdgeInsets.all(16),child:Text(en?'Preview templates only. Excel/PDF export is planned but not yet implemented.':'النماذج الحالية للعرض فقط؛ التصدير إلى Excel وPDF لم ينفذ بعد.'))
 ]);
}

class FinancialRatioModes extends StatefulWidget {
  final bool en;
  const FinancialRatioModes({super.key,required this.en});
  @override State<FinancialRatioModes> createState()=>_FinancialRatioModesState();
}
class _FinancialRatioModesState extends State<FinancialRatioModes>{
  bool comprehensive=false;
  @override Widget build(BuildContext context)=>Column(children:[
    Padding(padding:const EdgeInsets.all(8),child:SegmentedButton<bool>(
      segments:[
        ButtonSegment(value:false,label:Text(widget.en?'Single ratio':'نسبة منفردة')),
        ButtonSegment(value:true,label:Text(widget.en?'Full analysis':'تحليل شامل'))
      ],
      selected:{comprehensive},onSelectionChanged:(s)=>setState(()=>comprehensive=s.first))),
    Expanded(child:comprehensive?ComprehensiveRatiosScreen(en:widget.en):AccountingMetricsScreen(en:widget.en,depreciation:false))
  ]);
}
