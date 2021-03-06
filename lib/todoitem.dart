import 'dart:async';
import 'package:sqflite/sqflite.dart';

final String todoTable = "todo";
final String idColumn = "_id";
final String titleColumn = "title";
final String doneColumn = "done";

class TodoItem extends Comparable {
  int id;
  final String title;
  bool done;

  TodoItem({this.title, this.done = false});
  
  TodoItem.fromMap(Map<String, dynamic> map)
  : id = map[idColumn],
    title = map[titleColumn],
    done = map[doneColumn] == 1;  

  @override
  int compareTo(other) {
    if (this.done && !other.done) {
      return 1;
    } else if (!this.done && other.done) {
      return -1;
    } else {
      return this.id.compareTo(other.id);
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      titleColumn: title,
      doneColumn: done ? 1 : 0
    };
    // Allow for auto-increment
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }
}

class DataAccess {
  static final DataAccess _instance = DataAccess._internal();
  Database _db;

  factory DataAccess() {
    return _instance;
  }

  DataAccess._internal();

  Future open() async {

    String path = "todo.db";

    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            create table $todoTable ( 
            $idColumn integer primary key autoincrement, 
            $titleColumn text not null,
            $doneColumn integer not null)
            ''');
    });
  }

  Future<List<TodoItem>> getTodoItems() async {
    var data = await _db.query(todoTable);
    return data.map((d) => TodoItem.fromMap(d)).toList();
  }

  Future insertTodo(TodoItem item) {
    return _db.insert(todoTable, item.toMap());
  }

  Future updateTodo(TodoItem item) {
    return _db.update(todoTable, item.toMap(),
      where: "$idColumn = ?", whereArgs: [item.id]);
  }
  
  Future deleteTodo() {
    return _db.delete(todoTable, where: "$doneColumn = ?", whereArgs: [true]);
  }
}