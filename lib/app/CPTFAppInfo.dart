import 'package:flutter/foundation.dart';

import 'package:cptoolsflutter/db/CPTFAppDB.dart';
import 'package:cptoolsflutter/db/CPTFEntity.dart';

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

//#########################
// final int ACCOUNT_ROUTE_ITEM_IN_MENU = 0;

final int INITIAL_ROUTE_ITEM_IN_MENU = 0;

// initialRouteに対応するメニュー項目の位置 0, 1, ...

class CPTFAppInfo with ChangeNotifier {

  //-----------------

  // Drawerの選択状態を管理する
  int _currentDrawer = INITIAL_ROUTE_ITEM_IN_MENU;

  int get getCurrentDrawer => _currentDrawer;

  void setCurrentDrawer(int drawer) {
    _currentDrawer = drawer;
    notifyListeners();
  }

  /*
    import 'package:provider/provider.dart';

    Widget build(BuildContext context) {
      var currentDrawer = Provider.of<MyAppInfo>(context).getCurrentDrawer;
     ...

      Provider.of<MyAppInfo>(context).setCurrentDrawer(index);
     }
   */

  void increment() {
    notifyListeners();
  }

  //-----------------
  /*
  final List<Item> _items = [
    Item('a', 'b', 'c'),
    Item('1', '2', '3')
  ];

  List<Item> get items => List.unmodifiable(_items);

  int get numOfItems => _items.length;

  void addItem(Item item) {
    _items.add(item);
    notifyListeners();
  }
  */
  //-----------------
  //
  final Map<String, dynamic> _appDict = Map<String, dynamic>();

  Map<String, dynamic> get appDict => _appDict;

  void getAppDictValue(String key) {
    try {
      return _appDict[key];
    } catch (e) {
      return null;
    }
  }

  void setAppDictValue(String key, value) {
    try {
      _appDict[key] = value;
    } catch (e) {

    }
  }

  static final String KEY_SOMETHING = 'KEY_SOMETHING';

  static final String KEY_PROGRESS_TASK_AVORTED = 'KEY_PROGRESS_TASK_AVORTED';
  // ---> Usage
  // bool avorted = Provider.of<CPTFAppInfo>(context).getAppDictValue(MyAppInfo.KEY_PROGRESS_TASK_AVORTED) as bool;
  // Provider.of<CPTFAppInfo>(context).setAppDictValue(MyAppInfo.KEY_PROGRESS_TASK_AVORTED, true);

  //-----------------
  static final String KEY_PASSCODE_FOR_USER = 'KEY_PASSCODE_FOR_USER';

  // CPTFAppDB
  CPTFAppDB appdb = CPTFAppDB();

  Future<bool> openAppDB() async {
    return await appdb.openAppDB() as bool;
  }

  Future<Account> checkAccount() async {
    try {
      bool check = await appdb.openAppDB() as bool;

      print('database check in MyAppInfo');

      print(check);
      if (check == false) {
        return null;
      }

      Account entity = await appdb.selectFirstAccount() as Account;
      // ### ===> as AccountでFuture<Account>からAccountへ
      // ### 明示的に変換されるのを待つこと。
      // ### as Accountをなしにすると、nullとなってしまうので注意。

      // print('result');
      // print(entity.UserId);

      return entity;

    } catch (e) {

      return null;
    }
  }

  // アカウント登録（既存破棄で１件登録）
  Future<Account> saveAccount(Account entity) async {
    try {
      Account inserted = await appdb.saveAccount(entity) as Account;

      return inserted;
    } catch (e) {
      return null;
    }
  }

  // パスワード更新
  Future<bool> setPassword(String userId, String password) async {
    try {
      bool check = await appdb.setPassword(userId, password) as bool;
      return check;
    } catch (e) {
      return null;
    }
  }

  // パスコード（４桁数値を文字列にしたもの）を簡単パスワードとして保存する。
  Future<bool> setPasscode(String userId, String passcode) async {
    try {
      bool check = await appdb.setSimplePassword(userId, passcode) as bool;
      return check;
    } catch (e) {
      return null;
    }
  }
}
