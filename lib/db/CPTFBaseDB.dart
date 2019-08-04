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

// Dart packageのsqfliteは暗号化パスワードを使えないので、
// これとは別の、暗号化に対応したencrypted_sqflite-masterを取得して利用する。

class CPTFBaseDB {
  var logger = null;
  void log(String s) {
    if (logger != null) {
      logger.log(s);
    }
  }

  Future <String> futureTest(){
    return Future.delayed( Duration(seconds: 5), () async {
      return DateTime.now().toString();
    });
  }

  Future<Database> openDatabase(String dbFileName, String password, int version, bool deleteOld) async {
    var databasesPath = await getDatabasesPath();
    var ctx = p.Context(style: p.Style.posix);
    String path = ctx.join(databasesPath, dbFileName/*'demo.db'*/);
    log(path);

    print('Open Database at ' + path);

    if (deleteOld) {
      log('Delete the database');
      await deleteDatabase(path);
    }

    log('open the database');
    /*
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table

          log('CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
          await db.execute(
              "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
        });
    */

    OpenCallbacks cb = new OpenCallbacks();
    Database database = await cb.open(path, password, version: version);
    // ---> version指定を省略するとエラー。必ず入れること。

    return database;
  }

  Future<void> closeDatabase() async {
    log('Close the database');
    try {
      await database.close();
      database = null;
    } catch (e) {

    }
  }

  Database database = null;
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