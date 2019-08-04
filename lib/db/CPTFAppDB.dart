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

import 'package:cptoolsflutter/db/CPTFEntity.dart';

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

class CPTFAppDB extends CPTFBaseDB {
  String dbFileName = 'appdb.db';
  String password = '0000';
  int version = 1;
  bool deleteOld = false;

  Future<bool> openAppDB() async {
    return await _doOpenAppDB(dbFileName, password, version, deleteOld) as bool;
  }

  Future<bool> _doOpenAppDB(String dbFileName, String password, int version, bool deleteOld) async {
    if (database != null) {
      // 既存あり
      return true;
    }

    try {
      database = await super.openDatabase(dbFileName, password, version, deleteOld);

      //### アプリ初回インストール時点ではDBファイルが作られているが、
      //### テーブル定義は存在しない。
      //### ２回目以降は既存のテーブルが存在するのでそれが使われる。
      await createAppDB();

    } catch (e) {
      database = null;
      return false;
    }

    return (database != null) ? true : false;
  }

  //### テーブル作成。
  Future<void> createAppDB() async {

    try {
      //### DB Browser for SQLiteを使って、CREATE文をコピーするとよい。

      await database.execute('''
CREATE TABLE "KeyValueString"( "Key" varchar primary key not null , "Value" varchar )
    ''');

      await database.execute('''
CREATE TABLE "Account"( "UserId" varchar primary key not null , "Password" varchar , "SimplePassword" varchar )
    ''');

      await database.execute('''
CREATE TABLE "Bookmark"( "Id" integer primary key autoincrement not null , "userId" varchar , "itemLabel" varchar , "contents" varchar )
    ''');

      await database.execute('''
CREATE TABLE "DocInfo"( "Id" integer primary key autoincrement not null , "docId" varchar , "facilityId" varchar , "facilityPersonalId" varchar , "regionalId" varchar , "contentModuleType" varchar , "mmlVersion" varchar , "docInfo" varchar , "confirmDateJST" varchar , "confirmDateUTC" varchar , "title" varchar , "facilityName" varchar , "accountUserId" varchar )
    ''');

      await database.execute('''
CREATE TABLE "Document"( "Id" integer primary key autoincrement not null , "docId" varchar , "facilityId" varchar , "facilityPersonalId" varchar , "regionalId" varchar , "contentModuleType" varchar , "mmlVersion" varchar , "document" varchar , "parsed" varchar , "accountUserId" varchar )
    ''');

      await database.execute('''
CREATE TABLE "LaboTest"( "Id" integer primary key autoincrement not null , "userId" varchar , "facilityId" varchar , "spCode" varchar , "spName" varchar , "itemCode" varchar , "itemName" varchar , "sampleDatetimeJST" varchar , "itemValue" varchar , "itemUnit" varchar , "itemOut" varchar , "docInfoIntId" integer )
    ''');

      //### iOS Simulatorで実行した場合、
      //### 出来上がったappdb.dbファイルをDB Browser for SQLiteで
      //### Sqlite VersionをV4に指定してパスワードを入れるとデータベースを開くことができる。

    } catch (e) {

      // 既存のDBを使用している場合には、テーブルが既に定義されているので、エラーとなる。
      // ===> 通常は、そのままデータを使いたいので、処理を計測する。
    }
  }

  Future<void> closeAppDB() async {
    await database.close();
    database = null;
  }

  Future<List<Map>> list(String table, List<String> columns) async {
    List<Map> maps = await database.query(
        table,
        columns: columns);

    return maps;
  }

  Future<List<Map>> listByField(String table, List<String> columns,
      String fName, String fValue,
      bool like, String orderBy
      ) async {

    List<Map> maps = null;

    if (orderBy == null) {
      maps = await database.query(
          table,
          columns: columns,
          where: (like == true ? '$fName like ?' : "$fName = ?"),
          whereArgs: [fValue]);
    } else {
      maps = await database.query(
          table,
          columns: columns,
          where: (like == true ? '$fName like ?' : "$fName = ?"),
          whereArgs: [fValue],
          orderBy: orderBy);
    }

    return maps;
  }

  Future<Map> selectById(String table, List<String> columns, int Id) async {

    List<Map> maps = await database.query(
        table,
        columns: columns,
        where: "$fId = ?",
        whereArgs: [Id]);

    if (maps.length > 0) {
      return maps.first;
    }
    return null;
  }

  Future<Map> selectByField(String table, List<String> columns, String fName, String fValue) async {

    List<Map> maps = await database.query(
        table,
        columns: columns,
        where: "$fName = ?",
        whereArgs: [fValue]);

    if (maps.length > 0) {
      return maps.first;
    }
    return null;
  }

  Future<int> insert(String table, entity) async {
    // insertに成功すると、レコード・キーが返される。
    // entiryがIdを主キーに持っている場合は、適宜入力したentityにセットして使うと良い。
    return await database.insert(table, entity.toMap() as Map<String, dynamic>) as int;
  }

  Future<int> updateById(String table, entity) async {
    return await database.update(
        table,
        entity.toMap() as Map<String, dynamic>,
        where: "$fId = ?",
        whereArgs: [entity.Id]) as int;
  }

  Future<int> updateByField(String table, String fName, String fValue, entity) async {
    return await database.update(
        table,
        entity.toMap() as Map<String, dynamic>,
        where: "$fName = ?",
        whereArgs: [fValue]) as int;
  }

  Future<int> updateByCondition(String table, String where, List args, entity) async {
    return await database.update(
        table,
        entity.toMap() as Map<String, dynamic>,
        where: where,
        whereArgs: args) as int;
  }

  Future<int> deleteById(String table, int Id) async {
    return await database.delete(
        table,
        where: "$fId = ?",
        whereArgs: [Id]) as int;
  }

  Future<int> deleteAll(String table) async {
    return await database.delete(
        table) as int;
  }

  Future<int> deleteByField(String table, String fName, String fValue) async {
    return await database.delete(
        table,
        where: "$fName = ?",
        whereArgs: [fValue]) as int;
  }

  //------------------------------------------------------------------------------
  // ### SQL Wrapper

  // Account取得。最初の１件のみ
  Future<Account> selectFirstAccount() async {
    try {
      print('select Account');
      List<Map> maps = await list(
          fAccount,
          [fUserId, fPassword, fSimplePassword]);
      // print(maps);
      if (maps == null) {
        print('nothing');
        return null;
      }

      if (maps.length <= 0) {
        print('empty');
        return null;
      }

      Map<String, dynamic> map = maps.first as Map<String, dynamic>;
      if (map == null) {
        print('null as map');
        return null;
      }

      print('selectFirstAccount');
      print(map);
      Account entity = Account.fromMap(map);

      // print(entity);
      // print(entity.UserId);

      return entity;

    } catch (e) {
      print(e);
      return null;
    }
  }

  // Accoutを登録（１件のみ存在させる）
  Future<Account> saveAccount(Account entity) async {
    try {
      await openAppDB();
      // １件のみ存在させる
      await deleteAll(fAccount);

      int ins = await insert(fAccount, entity) as int;
      print('inserted $ins');
      // ===> 主キーはUserIdなので、ins(レコード内部キー）は不要。

      // print(entity);

      return entity;

    } catch (e) {
      return null;
    }
  }

  // パスワード更新
  Future<bool> setPassword(String userId, String password) async {
    try {
      await openAppDB();

      int count = await database.rawUpdate(
          'UPDATE $fAccount SET $fPassword = ? WHERE $fUserId = ?',
          [password, userId]);
      log("updated: $count");

      return (count > 0 ? true : false);

    } catch (e) {
      return null;
    }
  }

  // パスコード更新
  Future<bool> setSimplePassword(String userId, String simplePassword) async {
    try {
      await openAppDB();

      int count = await database.rawUpdate(
          'UPDATE $fAccount SET $fSimplePassword = ? WHERE $fUserId = ?',
          [simplePassword, userId]);
      log("updated: $count");

      return (count > 0 ? true : false);

    } catch (e) {
      return null;
    }
  }

  //---------

  Future<List<Map>> selectDocInfoIds(
      String accountUserId,
      String docId,
      String facilityId,
      String facilityPersonalId,
      String regionalId,
      String contentModuleType
      ) async {

    try {
      String sql = '''
        SELECT Id 
        FROM DocInfo 
        WHERE accountUserId=? 
          AND docId=? 
          AND facilityId=? 
          AND facilityPersonalId=? 
          AND regionalId=? 
          AND contentModuleType=?  
        ORDER BY confirmDateJST DESC
        ''';
      print(sql);
      print([accountUserId, docId, facilityId, facilityPersonalId, regionalId, contentModuleType]);
      List<Map> list = await database.rawQuery(sql, [accountUserId, docId, facilityId, facilityPersonalId, regionalId, contentModuleType]) as List<Map>;

      return list;

    } catch (e) {
      return null;
    }
  }

  Future<List<Map>> selectDocInfoForUser(
      String accountUserId
      ) async {

    try {
      String sql = '''
        SELECT Id, docId, facilityId, facilityPersonalId, regionalId, contentModuleType, 
        mmlVersion, 
        docInfo, 
        confirmDateJST, confirmDateUTC, title, facilityName, accountUserId 
        FROM DocInfo 
        WHERE accountUserId=? 
        ORDER BY confirmDateJST DESC
        ''';
      print(sql);
      print([accountUserId]);
      List<Map> list = await database.rawQuery(sql,[accountUserId]) as List<Map>;

      return list;

    } catch (e) {
      return null;
    }
  }

  Future<List<Map>> selectDocInfoForUserByKeyword(
      String accountUserId,
      String keyword
      ) async {

    try {
      // ### parsed文字列が出力しないでよい。

      String sql = '''
      SELECT DocInfo.* 
        FROM DocInfo INNER JOIN Document ON 
          DocInfo.docId=Document.docId 
          AND DocInfo.facilityId=Document.facilityId 
          AND DocInfo.facilityPersonalId=Document.facilityPersonalId 
          AND DocInfo.regionalId=Document.regionalId 
          AND DocInfo.contentModuleType=Document.contentModuleType 
          AND DocInfo.accountUserId=Document.accountUserId 
		  WHERE DocInfo.accountUserId=? AND Document.parsed LIKE ? 
		  ORDER BY DocInfo.confirmDateJST DESC
        ''';
      print(sql);
      print([accountUserId, keyword]);
      List<Map> list = await database.rawQuery(sql,[accountUserId, '%' + keyword + '%' ]) as List<Map>;

      return list;

    } catch (e) {
      return null;
    }
  }

  // ユーザのDocInfoのIdのみを取得する
  Future<List<Map>> selectDocInfoIdsForUser(
      String accountUserId
      ) async {

    try {
      String sql = '''
        SELECT Id 
        FROM DocInfo 
        WHERE accountUserId=? 
        ORDER BY confirmDateJST DESC
        ''';
      print(sql);
      print([accountUserId]);
      List<Map> list = await database.rawQuery(sql,[accountUserId]) as List<Map>;

      return list;

    } catch (e) {
      return null;
    }
  }

  Future<List<Map>> selectDocInfo(
      String accountUserId,
      String docId,
      String facilityId,
      String facilityPersonalId,
      String regionalId,
      String contentModuleType
      ) async {

    try {
      String sql = '''
        SELECT Id, docId, facilityId, facilityPersonalId, regionalId, contentModuleType, 
        mmlVersion, 
        docInfo, 
        confirmDateJST, confirmDateUTC, title, facilityName, accountUserId 
        FROM DocInfo 
        WHERE accountUserId=? 
          AND docId=? 
          AND facilityId=? 
          AND facilityPersonalId=? 
          AND regionalId=? 
          AND contentModuleType=? 
        ORDER BY confirmDateJST DESC
        ''';
      print(sql);
      print([accountUserId, docId, facilityId, facilityPersonalId, regionalId, contentModuleType]);
      List<Map> list = await database.rawQuery(sql, [accountUserId, docId, facilityId, facilityPersonalId, regionalId, contentModuleType]) as List<Map>;

      return list;

    } catch (e) {
      return null;
    }
  }

  // DocInfoをIdから取得してMapで返す。（１件ありなし）
  Future<Map> selectDocInfoById(
      int docInfoIdKey
      ) async {

    try {
      String sql = '''
        SELECT Id, docId, facilityId, facilityPersonalId, regionalId, contentModuleType, 
        mmlVersion, 
        docInfo, 
        confirmDateJST, confirmDateUTC, title, facilityName, accountUserId 
        FROM DocInfo 
        WHERE Id=? 
        ORDER BY confirmDateJST DESC
        ''';
      print(sql);
      print([docInfoIdKey]);

      List<Map> list = await database.rawQuery(sql, [docInfoIdKey]) as List<Map>;
      if (list != null && list.length > 0) {
        return list[0] as Map;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  // DocInfoを登録(Insert)
  Future<DocInfo> saveDocInfo(DocInfo entity) async {
    try {
      await openAppDB();
      // １件のみ存在させる

      int ins = await insert(fDocInfo, entity) as int;
      print('saveDocInfo inserted $ins');
      // 主キーIdをセットして返す。

      entity.Id = ins;

      // print(entity);

      return entity;

    } catch (e) {
      return null;
    }
  }

  //--------------

  // レコード重複チェックのためIdのみ取得する。
  Future<List<Map>> selectDocumentIds(
      String accountUserId,
      String docId,
      String facilityId,
      String facilityPersonalId,
      String regionalId,
      String contentModuleType
      ) async {

    try {
      String sql = '''
        SELECT Id 
        FROM Document  
        WHERE accountUserId=? 
          AND docId=? 
          AND facilityId=? 
          AND facilityPersonalId=? 
          AND regionalId=? 
          AND contentModuleType=? 
        ''';
      print(sql);
      print([accountUserId, docId, facilityId, facilityPersonalId, regionalId, contentModuleType]);
      List<Map> list = await database.rawQuery(sql, [accountUserId, docId, facilityId, facilityPersonalId, regionalId, contentModuleType]) as List<Map>;

      return list;

    } catch (e) {
      return null;
    }
  }

  // ユーザのDocInfoのIdのみを取得する
  Future<List<Map>> selectDDocumentIdsForUser(
      String accountUserId
      ) async {

    try {
      String sql = '''
        SELECT Id 
        FROM Document  
        WHERE accountUserId=? 
        ''';
      print(sql);
      print(
          [
            accountUserId
          ]
      );

      List<Map> list = await database.rawQuery(sql,
          [
            accountUserId
          ]
      ) as List<Map>;

      return list;

    } catch (e) {
      return null;
    }
  }

  Future<List<Map>> selectDocument(
      String accountUserId,
      String docId,
      String facilityId,
      String facilityPersonalId,
      String regionalId,
      String contentModuleType
      ) async {

    try {
      String sql = '''
        SELECT Id, docId, facilityId, facilityPersonalId, regionalId, contentModuleType, 
        mmlVersion, 
        document, 
        parsed, 
        accountUserId 
        FROM Document  
        WHERE accountUserId=? 
          AND docId=? 
          AND facilityId=? 
          AND facilityPersonalId=? 
          AND regionalId=? 
          AND contentModuleType=? 
        ''';
      print(sql);
      print([accountUserId, docId, facilityId, facilityPersonalId, regionalId, contentModuleType]);
      List<Map> list = await database.rawQuery(sql, [accountUserId, docId, facilityId, facilityPersonalId, regionalId, contentModuleType]) as List<Map>;

      return list;

    } catch (e) {
      return null;
    }
  }

  // Documentを登録(Insert)
  Future<Document> saveDocument(Document entity) async {
    try {
      await openAppDB();
      // １件のみ存在させる

      int ins = await insert(fDocument, entity) as int;
      print('saveDocument inserted $ins');
      // 主キーIdをセットして返す。

      entity.Id = ins;

      // print(entity);

      return entity;

    } catch (e) {
      return null;
    }
  }

  //----------------------------------------
  // DocInfo --- Document

  // DocInfoに対するDocumentが存在するかどうか、
  // DocInfoのIdからDocumentを検索する。
  Future<List<Map>> selectDocumentIdsByDocInfoIdKey(
      int docInfoIdKey
      ) async {

    try {
      String sql = '''
        SELECT 
          Document.Id 
        FROM Document INNER JOIN DocInfo ON 
          Document.docId=DocInfo.docId 
          AND Document.facilityId=DocInfo.facilityId 
          AND Document.facilityPersonalId=DocInfo.facilityPersonalId 
          AND Document.regionalId=DocInfo.regionalId 
          AND Document.contentModuleType=DocInfo.contentModuleType 
          AND Document.accountUserId=DocInfo.accountUserId  
        WHERE DocInfo.Id=?
        ''';
      print(sql);
      print('docInfoKey $docInfoIdKey');
      List<Map> list = await database.rawQuery(sql, [docInfoIdKey]) as List<Map>;

      return list;

    } catch (e) {
      return null;
    }
  }

  // DocInfoに対するDocumentが存在するかどうか、
  // DocInfoのIdからDocumentを検索する。
  Future<List<Map>> selectDocumentByDocInfoIdKey(
      int docInfoIdKey
      ) async {

    try {
      /*String sql = '''
        SELECT
          Document.Id,
          Document docId,
          Document.facilityId,
          Document facilityPersonalId,
          Document regionalId,
          Document contentModuleType,
          Document mmlVersion,
          Document document,
          Document parsed,
          Document accountUserId
        FROM Document INNER JOIN DocInfo ON
          Document.docId=DocInfo.docId
          AND Document.facilityId=DocInfo.facilityId
          AND Document.facilityPersonalId=DocInfo.facilityPersonalId
          AND Document.regionalId=DocInfo.regionalId
          AND Document.contentModuleType=DocInfo.contentModuleType
          AND Document.accountUserId=DocInfo.accountUserId
        WHERE DocInfo.Id=?
        ''';*/
      //===>カラム指定するとDB BrowserのSQL出力がおかしくなる。* にすると正常。

      String sql = '''
        SELECT * 
        FROM Document INNER JOIN DocInfo ON 
          Document.docId=DocInfo.docId 
          AND Document.facilityId=DocInfo.facilityId 
          AND Document.facilityPersonalId=DocInfo.facilityPersonalId 
          AND Document.regionalId=DocInfo.regionalId 
          AND Document.contentModuleType=DocInfo.contentModuleType 
          AND Document.accountUserId=DocInfo.accountUserId  
        WHERE DocInfo.Id=? 
        ''';
      print(sql);
      print('docInfoKey $docInfoIdKey');
      List<Map> list = await database.rawQuery(sql, [docInfoIdKey]) as List<Map>;

      // print('list ' + list.toString());

      return list;

    } catch (e) {
      return null;
    }
  }

  // ピボット　X軸
  // 採取日時の出現値をソートして求める
  Future<LaboTest> saveLaboTest(LaboTest entity) async {
    try {
      await openAppDB();

      int ins = await insert(fLaboTest, entity) as int;
      print('inserted $ins');

      entity.Id = ins;

      // print(entity);

      return entity;

    } catch (e) {
      return null;
    }
  }

  Future<List<Map>> selectLaboTestPivotX(
      String userId
      ) async {

    try {
      String sql = '''
SELECT DISTINCT 
 sampleDatetimeJST
FROM LaboTest 
WHERE userId=? 
ORDER BY sampleDatetimeJST
        ''';
      print(sql);
      print('userId ' + userId);
      List<Map> list = await database.rawQuery(sql, [userId]) as List<Map>;

      // print('list ' + list.toString());

      return list;

    } catch (e) {
      return null;
    }
  }

  Future<List<Map>> selectLaboTestPivotY(
      String userId
      ) async {

    try {
      String sql = '''
SELECT DISTINCT 
 facilityId, spCode, itemCode, spName, itemName, itemUnit
FROM LaboTest 
WHERE userId=?  
ORDER BY spName, itemName, itemUnit
        ''';
      print(sql);
      print('userId ' + userId);
      List<Map> list = await database.rawQuery(sql, [userId]) as List<Map>;

      // print('list ' + list.toString());

      return list;

    } catch (e) {
      return null;
    }
  }

  Future<List<Map>> selectLaboTestPivotZ(
      String userId,
      String facilityId,
      String spCode,
      String itemCode,
      String spName,
      String itemName,
      String itemUnit,
      String sampleDatetimeJST
      ) async {

    try {
      String sql = '''
SELECT DISTINCT 
 * 
FROM LaboTest 
WHERE userId=?  
AND facilityId=? 
AND spCode=? 
AND itemCode=?  
AND spName=?  
AND itemName=? 
AND itemUnit=? 
AND sampleDatetimeJST=? 
ORDER BY sampleDatetimeJST
        ''';
      print(sql);
      print('userId ' + userId);


      List<Map> list = await database.rawQuery(sql, [userId, facilityId, spCode, itemCode, spName, itemName, itemUnit, sampleDatetimeJST]) as List<Map>;

      // print('list ' + list.toString());

      return list;

    } catch (e) {
      return null;
    }
  }

  Future<List<Map>> selectLaboTestPivotRow(
      String userId,
      String facilityId,
      String spCode,
      String itemCode,
      String spName,
      String itemName,
      String itemUnit
      ) async {

    try {
      String sql = '''
SELECT DISTINCT 
 * 
FROM LaboTest 
WHERE userId=?  
AND facilityId=? 
AND spCode=? 
AND itemCode=?  
AND spName=?  
AND itemName=? 
AND itemUnit=? 
ORDER BY sampleDatetimeJST
        ''';
      print(sql);
      print('userId ' + userId);


      List<Map> list = await database.rawQuery(sql, [userId, facilityId, spCode, itemCode, spName, itemName, itemUnit]) as List<Map>;

      // print('list ' + list.toString());

      return list;

    } catch (e) {
      return null;
    }
  }

  //----------------------------------------------------------------------------
  // Bookmarkを登録(Insert)

  Future<Bookmark> saveBookmark(Bookmark entity) async {
    try {
      await openAppDB();
      // １件のみ存在させる

      int ins = await insert(fBookmark, entity) as int;
      print('saveDocInfo inserted $ins');
      // 主キーIdをセットして返す。

      entity.Id = ins;

      // print(entity);

      return entity;

    } catch (e) {
      return null;
    }
  }

  Future<List<Map>> selectBookmarkForUser(
      String accountUserId
      ) async {

    try {
      String sql = '''
        SELECT * 
        FROM Bookmark 
        WHERE userId=? 
        ORDER BY Id ASC
        ''';
      print(sql);
      print([accountUserId]);
      List<Map> list = await database.rawQuery(sql,[accountUserId]) as List<Map>;

      return list;

    } catch (e) {
      return null;
    }
  }

  // Bookmark entityについて、Id指定があればIdをつかって削除、
  // Idがnullならば、その他のフォールドを使って削除する。
  Future<int> deleteBookmark(Bookmark entity) async {

    int Id = entity.Id;
    if (Id != null) {
      return await database.delete(
          fBookmark,
          where: "$fId = ?",
          whereArgs: [Id]) as int;
    } else {
      return await database.delete(
          fBookmark,
          where: "$fuserId=? AND $fitemLabel=? AND $fcontents=?",
          whereArgs: [entity.userId, entity.itemLabel, entity.contents]) as int;
    }

  }


}