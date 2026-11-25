import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:accounting_bag/project_store.dart';

void main(){
  test('v1 projects survive v2 migration and history persists',() async {
    sqfliteFfiInit();
    databaseFactory=databaseFactoryFfi;
    final dir=await Directory.systemTemp.createTemp('bag_migration_');
    final path='${dir.path}/test.db';
    try{
      final old=await databaseFactory.openDatabase(path,options:OpenDatabaseOptions(version:1,onCreate:(db,version)=>db.execute('CREATE TABLE projects (name TEXT PRIMARY KEY, payload TEXT NOT NULL, updated INTEGER NOT NULL)')));
      await old.insert('projects',{'name':'existing','payload':'{}','updated':1});
      await old.close();
      final upgraded=await ProjectStore.openAt(path);
      expect((await upgraded.query('projects')).single['name'],'existing');
      await upgraded.insert('calculation_history',{'tool':'VAT','payload':'{}','created':2});
      await upgraded.close();
      final reopened=await ProjectStore.openAt(path);
      expect((await reopened.query('calculation_history')).single['tool'],'VAT');
      await reopened.close();
    }finally{
      await databaseFactory.deleteDatabase(path);
      await dir.delete(recursive:true);
    }
  });
}
