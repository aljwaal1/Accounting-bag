import 'dart:convert';
import 'package:sqflite/sqflite.dart';

class ProjectStore {
  static Future<Database>? _opening;
  static Future<Database> get database => _opening ??= _open();
  static Future<Database> _open() async {
    final directory=await getDatabasesPath();
    return openDatabase('$directory/accounting_projects.db',version:2,
      onCreate:(db,version) async {
        await db.execute('CREATE TABLE projects (name TEXT PRIMARY KEY, payload TEXT NOT NULL, updated INTEGER NOT NULL)');
        await _createHistory(db);
      },onUpgrade:(db,oldVersion,newVersion) async {
        if(oldVersion<2) await _createHistory(db);
      });
  }
  static Future<void> _createHistory(Database db) async {
    await db.execute('CREATE TABLE IF NOT EXISTS calculation_history (id INTEGER PRIMARY KEY AUTOINCREMENT, tool TEXT NOT NULL, payload TEXT NOT NULL, created INTEGER NOT NULL)');
  }
  static Future<void> saveCalculation(String tool, Map<String,dynamic> data) async {
    await (await database).insert('calculation_history',{'tool':tool,'payload':jsonEncode(data),'created':DateTime.now().millisecondsSinceEpoch});
  }
  static Future<List<Map<String,Object?>>> history() async => (await database).query('calculation_history',orderBy:'id DESC');
  static Future<void> deleteCalculation(int id) async {
    await (await database).delete('calculation_history',where:'id = ?',whereArgs:[id]);
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
