import 'package:flutter/material.dart';
import 'package:cptoolsflutter/app/CPTFDrawer.dart';

import 'package:flutter/services.dart';
import 'package:cptoolsflutter/cptoolsflutter.dart';
import 'package:provider/provider.dart';
import 'package:cptoolsflutter/app/CPTFAppInfo.dart';
import 'package:cptoolsflutter/db/CPTFEntity.dart';

import 'package:connectivity/connectivity.dart';

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

class CPTFHome extends StatefulWidget {
  @override
  _CPTFHomeState createState() => _CPTFHomeState();
}

class _CPTFHomeState extends State<CPTFHome> {

  @override
  void initState() {
    super.initState();

    _doInit();
  }

  _doInit() async {
    initPlatformState();

    // AppDBを確保する
    bool check = await _setupAppDB() as bool;
    // 失敗ならここで停止。
    if (check == false) return;

    //########################
    // GUIの表示が完了してcontextが有効になるまでに、少し待つ必要がある。
    // initState直後にダイアログを即時表示しようとするとクラッシュするので注意。
    await wait(100);
    //########################

    _checkWifi();

    _checkAccount();
  }

  //----------------------------------------------------------------------------
  String _platformVersion = 'Unknown';

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Cptoolsflutter.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  //----------------------------------------------------------------------------

  Future <String> wait(int milli){
    return Future.delayed( Duration(milliseconds: milli), () async {
      return DateTime.now().toString();
    });
  }

  //----------------------------------------------------------------------------

  Future<bool> _setupAppDB() async {
    await wait(500);

    bool opended = await Provider.of<CPTFAppInfo>(context).openAppDB() as bool;
    // ===> Future<bool> が boolとなるには、awaitを入れて完了を待つこと。
    //      awaitが無いと実行時エラーになる。

    print('Is AppDB opened: $opended');

    if (opended == false) {
      // アプリケーションの再起動を依頼する。
      String title = '初期化エラー';
      String message = 'データベースを準備できませんでした。\nアプリを再起動して下さい。';
      _showAlertMessage(context, title, message, 'OK', null);
    }

    return opended;
  }



  _checkAccount() async {
    //########################
    // GUIの表示が完了してcontextが有効になるまでに、少し待つ必要がある。
    // initState直後にダイアログを即時表示しようとするとクラッシュするので注意。
    await wait(100);
    //########################
    print('_checkAccount in MyHomePage');
    Account account = await Provider.of<CPTFAppInfo>(context).checkAccount() as Account;

    // DatabaseException(Error Domain=FMDatabase Code=1 "no such table: Account" UserInfo={NSLocalizedDescription=no such table: Account}) sql 'SELECT UserId, Password, SimplePassword FROM Account' args []}

    if (account == null) {
      try {
        _showAccountAlert(context, "アカウント未設定" , "アカウント設定を行って下さい。");
      } catch (e, s) {
        print(s);
      }
      return;

    } else {
      // ユーザID、パスワード
      if (account.UserId == null || account.Password == null) {
        try {
          _showAccountAlert(context, "アカウント未設定" , "アカウント設定でアカウント登録を行って下さい");
        } catch (e, s) {
          print(s);
        }
        return;
      }/* else if (account.SimplePassword == null) {
        // パスコード
        try {
          _showAccountAlert(context, "アカウント未設定" , "アカウント設定でパスコード登録を行って下さい");
        } catch (e, s) {
          print(s);
        }
        return;
      }*/
    }

    print(account.toMap().toString());

  }

  void _showAccountAlert(BuildContext context, String title, String message) {
    _showAlertMessage(context, title, message, 'OK', '/logincritter');
  }

  //----------------------------------------------------------------------------

  // WiFi
  // https://stackoverflow.com/questions/52164369/show-alert-dialog-on-app-main-screen-load-automatically-in-flutter
  // WiFi Check
  // 注意:/Users/penelope/Documents/Flutter_Install/flutter/.pub-cache/hosted/pub.dartlang.org/connectivity-0.4.3+2/android/src/main/java/io/flutter/plugins/connectivity/ConnectivityPlugin.javaは非推奨のAPIを使用またはオーバーライドしています。
  // 注意:詳細は、-Xlint:deprecationオプションを指定して再コンパイルして下さい。
  bool _tryAgain = false;

  _checkWifi() async {
    await wait(200);

    // the method below returns a Future
    var connectivityResult = await (new Connectivity().checkConnectivity());
    bool connectedToWifi = (connectivityResult == ConnectivityResult.wifi);

    /*
    if (!connectedToWifi) {
      // WiFiが無効なのでアラートを表示する。
      // #### 既にコンテキストは生成されている。
      _showAlert(context);
    }
    */

    if (_tryAgain != !connectedToWifi) {
      setState(() => _tryAgain = !connectedToWifi);
    }
  }

  void _showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("WiFi確認"),
          content: Text("WiFiを有効にして下さい。"),
        )
    );
  }

  //----------------------------------------------------------------------------

  _onPressedDialog(String routeNameAfterOk) async {

    Navigator.of(context).pop();

    // https://qiita.com/superman9387/items/9f5391368b933b7ac217
    if (routeNameAfterOk != null) {
      var result = await Navigator.of(context).pushNamed(routeNameAfterOk);

      updateNow();
    }
  }

  void _showAlertMessage(BuildContext context, String title, String message, String yes, String routeNameAfterOk) {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: new Text(title),
        content: new Text(message),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text(yes),
            onPressed: () => _onPressedDialog(routeNameAfterOk),
          ),
        ],
      ),
    );
  }

  String _dummy;

  void updateNow() {
    print('Home updateNow');

    _checkAccount();

    setState(() {
      _dummy = DateTime.now().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Text('Running on: $_platformVersion\n'),
      ),
      drawer: CPTFDrawer('Home', this),
    );
  }
}