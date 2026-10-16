import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pure financial formulas: rates are entered as percentages (e.g. 8 = 8%).
class FinanceMath {
  static double simple(double p,double rate,double years)=>p*(1+rate/100*years);
  static double compound(double p,double rate,double years,int periods)=>p*math.pow(1+rate/100/periods,years*periods).toDouble();
  static double effectiveRate(double nominal,int periods)=>(math.pow(1+nominal/100/periods,periods)-1)*100;
  static double presentValue(double future,double rate,double years)=>future/math.pow(1+rate/100,years);
  static double futureValue(double present,double rate,double years)=>present*math.pow(1+rate/100,years);
  static double annuityFuture(double payment,double rate,int periods){
    final r=rate/100;
    return r==0?payment*periods:payment*(math.pow(1+r,periods)-1)/r;
  }
  static double loanPayment(double principal,double rate,int periods){
    final r=rate/100;
    return r==0?principal/periods:principal*r/(1-math.pow(1+r,-periods));
  }
  static double cagr(double start,double end,double years)=>(math.pow(end/start,1/years)-1)*100;
}

class FinanceToolsScreen extends StatefulWidget {
  final bool en;
  const FinanceToolsScreen({super.key,required this.en});
  @override State<FinanceToolsScreen> createState()=>_FinanceToolsState();
}
class _FinanceToolsState extends State<FinanceToolsScreen> {
  int mode=0;
  final fields=List.generate(4,(_)=>TextEditingController());
  String? answer;
  String t(String ar,String en)=>widget.en?en:ar;
  @override void dispose(){for(final c in fields){c.dispose();}super.dispose();}
  @override Widget build(BuildContext context){
    final titles=[
      t('الفائدة البسيطة','Simple interest'),
      t('الفائدة المركبة','Compound interest'),
      t('معدل الفائدة الفعلي','Effective annual rate'),
      t('القيمة الحالية','Present value'),
      t('القيمة المستقبلية','Future value'),
      t('القيمة المستقبلية للدفعات','Future value of annuity'),
      t('القسط الدوري للقرض','Loan installment'),
      t('معدل النمو المركب','CAGR')
    ];
    final labels=[
      [t('أصل المبلغ','Principal'),t('الفائدة السنوية %','Annual rate %'),t('المدة بالسنوات','Years')],
      [t('أصل المبلغ','Principal'),t('الفائدة السنوية %','Annual rate %'),t('المدة بالسنوات','Years'),t('مرات التركيب سنويًا','Compounds per year')],
      [t('المعدل الاسمي السنوي %','Nominal annual rate %'),t('مرات التركيب سنويًا','Compounds per year')],
      [t('المبلغ المستقبلي','Future amount'),t('معدل الخصم السنوي %','Annual discount rate %'),t('المدة بالسنوات','Years')],
      [t('المبلغ الحالي','Present amount'),t('الفائدة السنوية %','Annual rate %'),t('المدة بالسنوات','Years')],
      [t('الدفعة الدورية','Payment per period'),t('الفائدة لكل فترة %','Rate per period %'),t('عدد الدفعات','Number of payments')],
      [t('مبلغ القرض','Loan principal'),t('الفائدة لكل فترة %','Rate per period %'),t('عدد الأقساط','Number of installments')],
      [t('القيمة الابتدائية','Starting value'),t('القيمة النهائية','Ending value'),t('المدة بالسنوات','Years')]
    ];
    void calculate(){
      final values=<double>[];
      for(var i=0;i<labels[mode].length;i++){
        final value=double.tryParse(fields[i].text.trim().replaceAll(',',''));
        if(value==null || !value.isFinite){
          setState(()=>answer=t('أدخل أرقامًا صحيحة لجميع الحقول','Enter valid numbers in all fields'));return;
        }
        values.add(value);
      }
      final a=values[0],b=values[1],c=values.length>2?values[2]:0;
      double? result;
      final count=values.length>3?values[3]:b;
      final validCount=count>0 && count==count.roundToDouble() && count<=365;
      final validPeriods=c>0 && c==c.roundToDouble() && c<=1200;
      switch(mode){
        case 0: if(a>=0 && b>=0 && c>=0)result=FinanceMath.simple(a,b,c);break;
        case 1: if(a>=0 && b>=0 && c>=0 && validCount)result=FinanceMath.compound(a,b,c,count.toInt());break;
        case 2: if(a>=0 && validCount)result=FinanceMath.effectiveRate(a,count.toInt());break;
        case 3: if(a>=0 && b>=0 && c>=0)result=FinanceMath.presentValue(a,b,c);break;
        case 4: if(a>=0 && b>=0 && c>=0)result=FinanceMath.futureValue(a,b,c);break;
        case 5: if(a>=0 && b>=0 && validPeriods)result=FinanceMath.annuityFuture(a,b,c.toInt());break;
        case 6: if(a>0 && b>=0 && validPeriods)result=FinanceMath.loanPayment(a,b,c.toInt());break;
        case 7: if(a>0 && b>0 && c>0)result=FinanceMath.cagr(a,b,c);break;
      }
      setState(()=>answer=result==null || !result.isFinite?t('تحقق من القيم والمدة والمعدلات','Check values, terms and rates'):
        '${t('النتيجة','Result')}: ${result.toStringAsFixed(2)}${mode==2 || mode==7?'%':''}');
    }
    return ListView(padding:const EdgeInsets.all(12),children:[
      Text(t('الرياضيات المالية والفوائد','Financial mathematics & interest'),style:Theme.of(context).textTheme.titleLarge),
      const SizedBox(height:12),
      DropdownButtonFormField<int>(initialValue:mode,isExpanded:true,
        items:List.generate(titles.length,(i)=>DropdownMenuItem(value:i,child:Text(titles[i],overflow:TextOverflow.ellipsis))),
        onChanged:(v)=>setState((){mode=v??0;answer=null;for(final f in fields){f.clear();}})),
      const SizedBox(height:12),
      for(var i=0;i<labels[mode].length;i++)Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(
        controller:fields[i],keyboardType:const TextInputType.numberWithOptions(decimal:true),
        decoration:InputDecoration(labelText:labels[mode][i],border:const OutlineInputBorder()))),
      FilledButton(onPressed:calculate,child:Text(t('احسب','Calculate'))),
      if(answer!=null)Padding(padding:const EdgeInsets.all(12),child:SelectableText(answer!,style:Theme.of(context).textTheme.titleMedium)),
      Text(t('في الدفعات والقروض: أدخل معدل الفائدة لكل فترة دفع، وليس المعدل السنوي. تُفترض الدفعات في نهاية الفترة.','For annuities and loans enter the rate per payment period, not the annual rate. Payments are assumed at period end.')),
    ]);
  }
}
