double? parseAccountingNumber(String input) {
  var s=input.trim().replaceAll('٬',',').replaceAll('٫','.').replaceAll('−','-');
  s=s.split('').map((ch){
    final a='٠١٢٣٤٥٦٧٨٩'.indexOf(ch), b='۰۱۲۳۴۵۶۷۸۹'.indexOf(ch);
    return a>=0?a.toString():b>=0?b.toString():ch;
  }).join();
  if(s.contains(',')&&!RegExp(r'^[+-]?\d{1,3}(,\d{3})+(\.\d+)?$').hasMatch(s))return null;
  final value=double.tryParse(s.replaceAll(',',''));
  return value!=null&&value.isFinite?value:null;
}
