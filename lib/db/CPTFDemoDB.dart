import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'dart:async';

import 'package:path/path.dart' as p;

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as d;
import 'dart:io';

import 'dart:convert' show json;
import 'dart:convert' show utf8;

import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:cptoolsflutter/db/CPTFBaseDB.dart';

/*
MIT License

Copyright (c) 2019 Code Propagator

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

class CPTFDemoDB extends CPTFBaseDB {

  //----------------------------------------------------------------------------
  // demo.db
  Future<void> runDB() async {

    // https://qiita.com/akatsukaha/items/f7c4fa9746e69f9b458d
    log(new DateTime.now().toString());
    //var result = await futureTest();
    //log(result);

    Database database = await super.openDatabase('demo.db', 'secret', 1, true);

    log(
        'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
    await database.execute(
        "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");


    log('Insert some records in a transaction');
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
      log("inserted1: $id1");

      int id2 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
          ["another name", 12345678, 3.1416]);
      log("inserted2: $id2");
    });

    log(')Update some record');
    int count = await database.rawUpdate(
        'UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',
        ["updated name", "9876", "some name"]);
    log("updated: $count");

    log('Get the records');
    List<Map> list = await database.rawQuery('SELECT * FROM Test');
    List<Map> expectedList = [
      {"name": "updated name", "id": 1, "value": 9876, "num": 456.789},
      {"name": "another name", "id": 2, "value": 12345678, "num": 3.1416}
    ];
    log(list.toString());
    log(expectedList.toString());
    // assert(const DeepCollectionEquality().equals(list, expectedList));

    log(')Count the records');
    count = Sqflite
        .firstIntValue(await database.rawQuery("SELECT COUNT(*) FROM Test"));
    log('count = $count');
    assert(count == 2);

    log(')Delete a record');
    count = await database
        .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
    log('count = $count');
    assert(count == 1);

    log('Close the database');
    await database.close();
  }

  Database database = null;

  Future<void> runDBEntity() async {
    // https://qiita.com/akatsukaha/items/f7c4fa9746e69f9b458d
    log(new DateTime.now().toString());
    //var result = await futureTest();
    //log(result);

    database = await super.openDatabase('demo.db', 'secret', 1, true);

    await database.execute('''
      create table $tableTodo ( 
        $columnId integer primary key autoincrement, 
        $columnTitle text not null,
        $columnDone integer not null
        )''');

    // 新規レコード
    log('新規レコード');
    Todo todo = Todo.fromMap({
      columnId: null,
      columnTitle:'タイトル',
      columnDone: false // true or false ---> mapped to 1 or 0 for db
    });

    Todo inserted = await insert(todo);
    inserted != null ?
    log(inserted.toMap().toString()) :
    log('書き込みエラー');


    log('レコード取得');
    Todo selected = await getTodo(1);

    selected != null ?
    log(selected.toMap().toString()) :
    log('なし');


    log('レコード更新');
    Todo updated = await getTodo(1);
    updated.title = 'タイトル変更';
    updated.done = true;

    updated != null ?
    log(updated.toMap().toString()) :
    log('更新エラー');

    log('----');
    log('全件');
    List<Todo> list = await listTodo();
    for (Todo todo in list) {
      log(todo.toMap().toString());
    }
    log('----');

    log('削除');
    int del = await delete(1);
    log('deleted count $del');

    log('Close the database');
    await database.close();
    database = null;
  }

  Future<Todo> insert(Todo todo) async {
    todo.id = await database.insert(tableTodo, todo.toMap()) as int;
    return todo;
  }

  Future<List<Todo>> listTodo() async {

    List<Map> maps = await database.query(
        tableTodo,
        columns: [columnId, columnDone, columnTitle]);

    List<Todo> list = List<Todo>();
    if (maps.length > 0) {
      for (Map map in maps) {
        list.add(Todo.fromMap(map));
      }
    }
    return list;
  }

  Future<Todo> getTodo(int id) async {

    List<Map> maps = await database.query(
        tableTodo,
        columns: [columnId, columnDone, columnTitle],
        where: "$columnId = ?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return new Todo.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await database.delete(
        tableTodo,
        where: "$columnId = ?",
        whereArgs: [id]);
  }

  Future<int> update(Todo todo) async {
    return await database.update(
        tableTodo,
        todo.toMap(),
        where: "$columnId = ?",
        whereArgs: [todo.id]);
  }
}

//------------------------------------------------------------------------------
// Entity

final String tableTodo = "todo";

final String columnId = "_id";
final String columnTitle = "title";
final String columnDone = "done";

class Todo {
  int id;
  String title;
  bool done;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      columnTitle: title,
      columnDone: done == true ? 1 : 0
    };
    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }

  Todo();

  Todo.fromMap(Map map) {
    id = (map[columnId] == null ? null : map[columnId] as int);
    title = map[columnTitle] as String;
    done = map[columnDone] == 1;
  }
}

//------------------------------------------------------------------------------
class OpenCallbacks {
  bool onConfigureCalled;
  bool onOpenCalled;
  bool onCreateCalled;
  bool onDowngradeCalled;
  bool onUpgradeCalled;

  void reset() {
    onConfigureCalled = false;
    onOpenCalled = false;
    onCreateCalled = false;
    onDowngradeCalled = false;
    onUpgradeCalled = false;
  }

  OnDatabaseCreateFn onCreate;
  OnDatabaseConfigureFn onConfigure;
  OnDatabaseVersionChangeFn onDowngrade;
  OnDatabaseVersionChangeFn onUpgrade;
  OnDatabaseOpenFn onOpen;

  OpenCallbacks() {
    onConfigure = (Database db) {
      onConfigureCalled = true;
    };

    onCreate = (Database db, int version) {
      onCreateCalled = true;
    };

    onOpen = (Database db) {
      onOpenCalled = true;
    };

    onUpgrade = (Database db, int oldVersion, int newVersion) {
      onUpgradeCalled = true;
    };

    onDowngrade = (Database db, int oldVersion, int newVersion) {
      onDowngradeCalled = true;
    };

    reset();
  }

  Future<Database> open(String path, String password, {int version}) async {
    reset();
    return await databaseFactory.openDatabase(path, password,
        options: new OpenDatabaseOptions(
            version: version,
            onCreate: onCreate,
            onConfigure: onConfigure,
            onDowngrade: onDowngrade,
            onUpgrade: onUpgrade,
            onOpen: onOpen));
  }
}