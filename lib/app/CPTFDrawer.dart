import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cptoolsflutter/app/CPTFAppInfo.dart';

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

class CPTFDrawer extends StatelessWidget {

  CPTFDrawer(this.currentPage, this.home);

  final String currentPage;

  final home;

  _onTapItem(BuildContext context,
      var currentDrawer,
      String title, int index, String routeName, bool replace) async {

    // Drawerを隠す
    Navigator.of(context).pop();

    // 同じページには遷移する必要なし
    if (this.currentPage == title) return;

    // プログレス処理の場合は、再び画面遷移をする前に、ロック解除する。
    if (routeName == '/progresstask') {
      print('ロック解除');
      Provider.of<CPTFAppInfo>(context).setAppDictValue(CPTFAppInfo.KEY_PROGRESS_TASK_AVORTED, false);
    }

    print('Drawer currentPage');
    print(currentPage);
    print('new routeName ' + routeName);

    if (routeName == '/') {
      // ### DrawerはHomeのみで使用するので、
      // ### Homeを重複してプッシュしないようにする。
      return;
    }

    if (replace) {

      // 画面繊維した先でもDrawerを表示する場合、
      // currentDrawerの値を変更する。
      Provider.of<CPTFAppInfo>(context).setCurrentDrawer(index);

      print('pushReplacementNamed routeName ' + routeName);

      // 画面繊維（置き換えして戻らない）
      Navigator.of(context).pushReplacementNamed(routeName);

    } else {

      // プッシュして戻ってくる想定。
      // currentDrawerの値は変更しないでおく。

      print('pushNamed routeName ' + routeName);

      // 画面繊維（ポップで戻る）
      var result = await Navigator.of(context).pushNamed(routeName);

      print('poped from route');
      print(result);

      print('currentPage');
      print(currentPage);

      try {
        if (this.home != null) {
          this.home.updateNow();
        }
      } catch (e) {

      }
    }
  }

  Widget addListItem(
      BuildContext context,
      var currentDrawer,
      String title, int index, String routeName, bool replace) {

    return ListTile(
      title: Text(
        title,
        style: currentDrawer == index
            ? TextStyle(fontWeight: FontWeight.bold)
            : TextStyle(fontWeight: FontWeight.normal),
      ),
      trailing: Icon(Icons.arrow_forward),
      onTap: () => _onTapItem(context,
          currentDrawer,
          title, index, routeName, replace),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentDrawer = Provider.of<CPTFAppInfo>(context).getCurrentDrawer;

    //#############
    // 以下、Drawerのリスト項目を生成する。
    // 画面繊維のルート名とpush方式（push/pop形式か、pushReplace形式かの）指定を行う。
    // ===> pushReplaceで遷移すると、CPTFDrawer自体が消失するので、状態管理が複雑になる。
    // 　　　CPTFHomeにのみCPTFDrawerを配置しておき、
    // 　　　push/pop方式で、必ず呼び出し元にpopで戻ってくるようにするのがシンプルでよい。
    //
    // main.dartの定義項目を調整しておくこと。
    // final int INITIAL_ROUTE_ITEM_IN_MENU = 3;
    //#############
    return Drawer(
      child: ListView(
        children: <Widget>[
          addListItem(context, currentDrawer, "ホーム", INITIAL_ROUTE_ITEM_IN_MENU, '/', false) as Widget,

          addListItem(context, currentDrawer, "Item Selection", 1, '/itemselection', false) as Widget,
          addListItem(context, currentDrawer, "Item Selection 2", 2, '/itemselection2', false) as Widget,
          addListItem(context, currentDrawer, "MasterDetail", 3, '/masterdetail', false) as Widget,
          addListItem(context, currentDrawer, "Progress Task", 4, '/progresstask', false) as Widget,
          addListItem(context, currentDrawer, "Multi Charts", 5, '/multicharts', false) as Widget,
          addListItem(context, currentDrawer, "Single Chart", 6, '/singlechart', false) as Widget,
          addListItem(context, currentDrawer, "Line CHart", 7, '/linechart', false) as Widget,
          addListItem(context, currentDrawer, "Sync Scroll", 8, '/syncscroll', false) as Widget,
          addListItem(context, currentDrawer, "Login Critter", 9, '/logincritter', false) as Widget,
          addListItem(context, currentDrawer, "Login", 10, '/login', false) as Widget,
          addListItem(context, currentDrawer, "Passcode", 11, '/newpasscode', false) as Widget,


          Divider(),

        ],
      ),
    );
  }
}
