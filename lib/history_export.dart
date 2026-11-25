import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart' as xl;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class HistoryExport {
  static List<List<String>> rows(List<Map<String,Object?>> history,bool en) {
    final output=<List<String>>[[en?'Tool':'الأداة',en?'Date UTC':'التاريخ UTC',en?'Type':'النوع',en?'Field':'البند',en?'Value':'القيمة']];
    for(final row in history){
      final data=jsonDecode(row['payload'] as String) as Map;
      final tool=row['tool'].toString();
      final date=DateTime.fromMillisecondsSinceEpoch(row['created'] as int,isUtc:true).toIso8601String();
      for(final entry in (data['inputs'] as Map).entries){
        output.add([tool,date,en?'Input':'مدخل',entry.key.toString(),entry.value.toString()]);
      }
      for(final result in data['results'] as List){
        final line=result.toString();
        final split=line.lastIndexOf(': ');
        output.add([tool,date,en?'Result':'نتيجة',split<0?line:line.substring(0,split),split<0?'':line.substring(split+2)]);
      }
    }
    return output;
  }
  static String csv(List<List<String>> rows) {
    String cell(String value){
      final numeric=double.tryParse(value);
      final safe=RegExp(r'^\s*[=+@-]').hasMatch(value)&&numeric==null?"'$value":value;
      return '"${safe.replaceAll('"','""')}"';
    }
    return '\uFEFF${rows.map((r)=>r.map(cell).join(',')).join('\r\n')}';
  }
  static Uint8List excel(List<List<String>> rows){
    final book=xl.Excel.createExcel();
    final sheet=book['Sheet1'];
    for(final row in rows){
      sheet.appendRow(row.asMap().entries.map<xl.CellValue>((e){
        final number=e.key==4?double.tryParse(e.value):null;
        return number!=null&&number.isFinite?xl.DoubleCellValue(number):xl.TextCellValue(e.value);
      }).toList());
    }
    final bytes=book.encode();
    if(bytes==null)throw StateError('Excel encoding failed');
    return Uint8List.fromList(bytes);
  }
  static Future<void> share(List<Map<String,Object?>> history,bool en,String format) async {
    final data=rows(history,en);
    if(format=='PDF'){
      final font=pw.Font.ttf(await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'));
      final doc=pw.Document();
      doc.addPage(pw.MultiPage(theme:pw.ThemeData.withFont(base:font),textDirection:en?pw.TextDirection.ltr:pw.TextDirection.rtl,build:(_)=>[
        pw.Text(en?'Calculation history':'سجل الحسابات',style:pw.TextStyle(fontSize:20)),
        for(final row in data.skip(1))pw.Padding(padding:const pw.EdgeInsets.only(bottom:6),child:pw.Text(row.join(' | ')))
      ]));
      await Printing.sharePdf(bytes:await doc.save(),filename:'calculation-history.pdf');
    }else{
      final isCsv=format=='CSV';
      final bytes=isCsv?Uint8List.fromList(utf8.encode(csv(data))):excel(data);
      await Share.shareXFiles([XFile.fromData(bytes,mimeType:isCsv?'text/csv':'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],fileNameOverrides:[isCsv?'calculation-history.csv':'calculation-history.xlsx']);
    }
  }
}
