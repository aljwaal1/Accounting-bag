import 'dart:convert';
import 'package:sqflite/sqflite.dart';

class ProjectStore {
  static Future<Database>? _opening;
  static Future<Database> get database => _opening ??= _open();
  static Future<Database> _open() async {
    final directory=await getDatabasesPath();
    return openDatabase('$directory/accounting_projects.db',version:1,
      onCreate:(db,version)=>db.execute('CREATE TABLE projects (name TEXT PRIMARY KEY, payload TEXT NOT NULL, updated INTEGER NOT NULL)'));
  }
  static Future<void> save(String name, Map<String,dynamic> data) async {
    if(name.trim().isEmpty)throw ArgumentError('Project name required');
    await (await database).insert('projects',{'name':name.trim(),'payload':jsonEncode(data),'updated':DateTime.now().millisecondsSinceEpoch},conflictAlgorithm:ConflictAlgorithm.replace);
  }
  static Future<List<String>> names() async =>
    (await (await database).query('projects',columns:['name'],orderBy:'updated DESC')).map((r)=>r['name'] as String).toList();
  static Future<Map<String,dynamic>?> load(String name) async {
    final rows=await (await database).query('projects',where:'name = ?',whereArgs:[name],limit:1);
    return rows.isEmpty?null:Map<String,dynamic>.from(jsonDecode(rows.first['payload'] as String) as Map);
  }
}
