import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_bag/history_export.dart';
import 'package:excel/excel.dart' as xl;

void main(){
  test('history rows retain inputs and results',(){
    final rows=HistoryExport.rows([{'tool':'VAT','created':0,'payload':jsonEncode({'inputs':{'Gross':120},'results':['Tax: 20.00']})}],true);
    expect(rows.length,3);
    expect(rows[1].last,'120');
    expect(rows[2].last,'20.00');
  });
  test('CSV quotes, Arabic, negative numbers and formula protection',(){
    final csv=HistoryExport.csv([['عربي','a"b','-20','=1+1']]);
    expect(csv,'\uFEFF"عربي","a""b","-20","\'=1+1"');
  });
  test('Excel numeric cells survive encoding',(){
    final book=xl.Excel.decodeBytes(HistoryExport.excel([['VAT','date','Result','Tax','20.00']]));
    expect(book['Sheet1'].rows.first[4]?.value,xl.DoubleCellValue(20));
  });
}
