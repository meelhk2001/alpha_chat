import 'package:alphachat/helpers/message_modal.dart';
import 'package:alphachat/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqlbrite/sqlbrite.dart' ;
import '../screens/chat_screen.dart';

class DBHelper {
  static Future<void> delete(String table, String id, BuildContext context) async {
    final db = await DBHelper.database(table);
    await db.delete(table, where: 'id = $id');
    Chat.of(context).setState(() {});
    print(id);
  }

  static Future<sql.Database> database(String groupChatId) async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, '$groupChatId.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE IF NOT EXISTS $groupChatId(id TEXT PRIMARY KEY, content TEXT, idFrom TEXT, idTo TEXT, read TEXT, timestamp TEXT)');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database(table);
    db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }
  static Future<void> update(String table, Map<String, Object> data) async{
    final db = await DBHelper.database(table);
    db.update(table, data, where: 'id = ?', whereArgs: [data['id']],conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Stream<List<Message>> getAllItems(String groupChatId) async* {
    final db = await DBHelper.database(groupChatId).then((db) => BriteDatabase(db));
    yield* db
        .createQuery(groupChatId)
        .mapToList((json) => Message.fromJson(json));
  }
  // static Future<sql.Database> getData(String groupChatId) async {
  //   await DBHelper.database(groupChatId).then((db) => BriteDatabase(db));
  //   return DBHelper.database(groupChatId);
  //   //return  db.query(table).asStream();
  // }
}
