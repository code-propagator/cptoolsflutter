import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:connectivity/connectivity.dart';

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

class CPTFProgressTask extends StatefulWidget {
  CPTFProgressTask({Key key, this.title}) : super(key: key);

  final String title;

  @override
  CPTFProgressTaskState createState() => CPTFProgressTaskState();
}

class CPTFProgressTaskState extends State<CPTFProgressTask> {
  //----------------
  // Progresss
  int statusCounter;
  String currentStatus;
  var progressValue = 0.0;// or null for indeterminate

  //--------------------
  @override
  void initState() {
    super.initState();
    print("MyHomePageState initState");

    _doInit();
  }

  static Future <String> wait(int milli) async {
    return Future.delayed( Duration(milliseconds: milli), () async {
      return DateTime.now().toString();
    });
  }

  void _doInit() async {
    _checkWifi();
  }

  //----------------
  // WiFi
  // https://stackoverflow.com/questions/52164369/show-alert-dialog-on-app-main-screen-load-automatically-in-flutter
  bool _tryAgain = false;

  _checkWifi() async {
    await wait(1000);

    // the method below returns a Future
    var connectivityResult = await (new Connectivity().checkConnectivity());
    bool connectedToWifi = (connectivityResult == ConnectivityResult.wifi);

    if (!connectedToWifi) {
      // WiFiが無効なのでアラートを表示する。
      // #### 既にコンテキストは生成されている。
      _showAlert(context, "WiFi確認", "WiFiを有効にして下さい。");
    }

    // WiFiが向こうで再確認ボタンが表示されていない場合は、
    // 再確認ボタンを表示するよう、ステータスを変更する。
    if (_tryAgain != !connectedToWifi) {
      setState(() => _tryAgain = !connectedToWifi);
    }
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
        )
    );
  }


  //----------------
  CPTFProgressTask() {
    statusCounter = 0;
    currentStatus = '開始ボタンを押して下さい。';
  }

  static mylogfunc(String s, SendPort replyPort, SendPort port) {
    print(s);

    // ロガーからの文字列は頻繁で、大量生成されるので、
    // タスクからレスポンスをポートで返すことは問題ないが、
    // 呼び出し側でステータス表示の更新が間に合わない。
    // ===> 調整するか、キューの検討が必要。
    /*
      replyPort.send([
        [1, DateTime.now().toString() + ': ' + s],
        port
      ]);
      */
  }


  static final String SAVE_TO_DATABASE = 'SAVE_TO_DATABASE';

  static final int FINISHED = -1;
  static final int FINISHED_ERROR = -2;
  static final int FINISHED_MORE = -3;

  // Isokateを使うのでstatic処理とする。
  static doTask(SendPort sendPort, ReceivePort receivePort, msg, data, int n, String s) async {

    print('#######################');
    print('#######################');
    print('#######################');
    print('doTask');
    print('#######################');
    print('#######################');
    print('#######################');

    //========
    // 処理開始
    //========

    // 応答するポートを確保
    SendPort replyPort = msg[1] as SendPort;

    print('elements');
    print(n);
    print(s);

    var answerData = [0, DateTime.now().toString() + ': 開始'];
    replyPort.send([answerData, receivePort.sendPort]);

    await wait(3000);

    // リストのパース（１件ずつループ）
    try {
      int listLen = 100;

      if (listLen > 0) {
        for (int k = 0; k < listLen; k++) {
          print('processing elements...$k');

          // ここでstopNowフラグは読めない。

          await wait(100);

          answerData = [
            (k + 1),
            DateTime.now().toString() + ': 項目 ' + (k + 1).toString() +
                ' of $listLen'
          ];
          print('sending answerData...$answerData');

          replyPort.send([answerData, receivePort.sendPort]);
        }
      }

      var finalAnswer = [FINISHED, DateTime.now().toString() + ': 完了'];
      print('Send FINAL ANSWER $finalAnswer');
      replyPort.send([finalAnswer, receivePort.sendPort]);

    } catch (e) {
      print('Login Error');

      var errorAnswer = [
        FINISHED_ERROR,
        DateTime.now().toString() + ': エラー'
      ];
      replyPort.send([errorAnswer, receivePort.sendPort]);

    }
  }

  static doMoreTask(SendPort sendPort, ReceivePort receivePort, msg, data, int n, String s) async {

    print('#######################');
    print('#######################');
    print('#######################');
    print('doMoreTask');
    print('#######################');
    print('#######################');
    print('#######################');

    //========
    // 処理開始
    //========

    // 応答するポートを確保
    SendPort replyPort = msg[1] as SendPort;

    print('elements');
    print(n);
    print(s);

    var answerData = [0, DateTime.now().toString() + ': 開始'];
    replyPort.send([answerData, receivePort.sendPort]);

    await wait(3000);

    // リストのパース（１件ずつループ）
    try {
      int listLen = 100;

      if (listLen > 0) {
        for (int k = 0; k < listLen; k++) {
          print('processing elements...$k');

          // ここでstopNowフラグは読めない。

          await wait(100);

          answerData = [
            (k + 1),
            DateTime.now().toString() + ': 項目 ' + (k + 1).toString() +
                ' of $listLen'
          ];
          print('sending answerData...$answerData');

          replyPort.send([answerData, receivePort.sendPort]);
        }
      }

      var finalAnswer = [FINISHED_MORE, DateTime.now().toString() + ': 完了'];
      print('Send FINAL ANSWER $finalAnswer');
      replyPort.send([finalAnswer, receivePort.sendPort]);

    } catch (e) {
      print('Login Error');

      var errorAnswer = [
        FINISHED_ERROR,
        DateTime.now().toString() + ': エラー'
      ];
      replyPort.send([errorAnswer, receivePort.sendPort]);

    }
  }

  /*
   * 長時間処理はIsolateを使うためstaticにする。
   */
  static MyLongTask(SendPort sendPort) async {
    // ロングタスク処理用のポートを作る
    ReceivePort receivePort = ReceivePort();

    // 呼び出し元にタスクのポートを返す。
    // 呼び出し元はこのポートを使ってデータ投入を行う。
    sendPort.send(receivePort.sendPort);

    await for (var msg in receivePort) {
      print('MyLongTask received data...');
      print(msg);

      var data = msg[0];
      print(data);

      if (data != null && data is List) {

        int n = data[0] as int;
        String s = data[1] as String;

        if (s == START_PROCESS_NOW) {
          await doTask(sendPort, receivePort, msg, data, n, s);
        }
        else if (s == START_MORE_PROCESS_NOW) {
          await doMoreTask(sendPort, receivePort, msg, data, n, s);
        }
        else {
          print('WRONG MESSSAGE FROM TASK EXECUTOR' + s);
          break;
        }
      }
      else {
        print('NOT A LIST');
      }
    }
  }

  //-------------------------
  // Progress
  static bool isBusy = false;// 開始時にBusyとする。
  static bool stopNow = false;// 中断したいタイミングでONにする。

  static final String START_PROCESS_NOW = 'START_PROCESS_NOW';

  static final String START_MORE_PROCESS_NOW = 'START_MORE_PROCESS_NOW';

  void _onPressedButton() async {
    print('_onPressedButton before download');

    //中止から画面繊維するまでの間に
    //実行ボタンを押されることもあるため、
    //ロック状態を取得する。
    bool avorted = Provider.of<CPTFAppInfo>(context).getAppDictValue(CPTFAppInfo.KEY_PROGRESS_TASK_AVORTED) as bool;

    if (avorted == true) {
      print('already avorded');
      return;
    }
    print('not avorted ever');

    if (isBusy == true) {
      print('BUSY');
      print("turn stop flag on");
      stopNow = true;

      // プログレス表示をを停止する。
      setState(() {
        progressValue = 0.0;
      });

      return;

    } else {

      print('not busy now');

      // START NEW  TASK
      isBusy = true;
      stopNow = false;

      //==========================

      // 結果受け取りポート
      final receivePort = ReceivePort();

      setState(() {
        statusCounter = 0;
        currentStatus = '処理を開始します。';
        progressValue = null;
      });

      // 長時間処理開始
      Isolate iso = await Isolate.spawn(MyLongTask, receivePort.sendPort) as Isolate;
      // print(iso);

      SendPort sendPort = null;
      ReceivePort answerReceiver = null;

      // タスクのポートを取得する。
      sendPort = await receivePort.first as SendPort;

      // タスクのポートに対して処理の実行を依頼するが、
      // 結果の受け取りは、専用のレシーバーを用意して、データと共に送る。

      String targetUserId = 'USER';
      String targetPassword = 'PASSWORD';

      //###############################################################
      // 開始メッセージをタスクに送る
      var data = [10, START_PROCESS_NOW, targetUserId, targetPassword];
      answerReceiver = ReceivePort();
      await sendPort.send([data, answerReceiver.sendPort]);
      //###############################################################

      // レシーバーでモニターして、進捗状況や処理結果を受け取る。
      // https://buildflutter.com/flutter-threading-isolates-future-async-and-await/
      await for (var answer in answerReceiver) {
        print('Got answer $answer');

        List answerData = answer[0] as List;
        int n = answerData[0] as int;
        String s = answerData[1] as String;

        // SendPort contiPort = answer[1] as SendPort;
        // ここで返信してもループ処理中のタスクでは処理完了後に内容が受け取られるので、
        // 処理中断はできない。

        print('stopNow ' + stopNow.toString());
        if (stopNow == true) {
          // 中断

          iso.kill();

          setState(() {
            statusCounter = FINISHED_ERROR;
            currentStatus = '処理を中止しました。';
          });

          stopNow = false;
          isBusy = false;

          // KEY_PROGRESS_TASK_AVORTED = true;
          print('ロック');
          Provider.of<CPTFAppInfo>(context).setAppDictValue(CPTFAppInfo.KEY_PROGRESS_TASK_AVORTED, true);

          break;

        } else {

          // 受け取り処理を継続

          if (s == SAVE_TO_DATABASE) {

            // 取得結果をデータベースに保存する

            continue;
          }
          else {

            // 通常のメッセージ表示処理

            setState(() {
              statusCounter = n;
              currentStatus = s;
            });

            // 完了またはエラー
            if (n == FINISHED_ERROR) {
              isBusy = false;
              stopNow = false;

              setState(() {
                progressValue = 0.0;
              });

              break;
            }
            else if (n == FINISHED) {
              print('タスク終了');

              bool doMoreTask = true;

              //###############################
              // 次のタスクのリクエストをだす。
              // 開始メッセージをタスクに送る
              if (doMoreTask) {

                print('#######################');
                print('#######################');
                print('START_MORE_PROCESS_NOW');
                print('#######################');
                print('#######################');

                var data = [
                  200,
                  START_MORE_PROCESS_NOW,
                  targetUserId,
                  targetPassword,
                  ['a','b','c']];
                // answerReceiver = ReceivePort();
                // ===> #### answerReceiverはそのまま確保済みのものを使う
                //      #### answerReceiverを入れ替えてしまうと処理を継続できないので注意。
                await sendPort.send([data, answerReceiver.sendPort]);

                continue;

              } else {
                print('終了');

                // 続いて処理する必要なし。

                isBusy = false;
                stopNow = false;

                setState(() {
                  progressValue = 0.0;
                });

                break;
              }
              //###############################

            } else if (n == FINISHED_MORE) {

              print('追加タスク終了');

              isBusy = false;
              stopNow = false;

              setState(() {
                progressValue = 0.0;
              });

              break;
            }
          }
        }
      }

      await wait(500);
      // Drawerの選択位置をルート画面にする。
      // Provider.of<MyAppInfo>(context).setCurrentDrawer(INITIAL_ROUTE_ITEM_IN_MENU);
      // ルート画面に繊維する。
      // Navigator.of(context).pushReplacementNamed('/');
      // ===> Replacementを使うと複数のルート画面が生成・消滅を繰り返すので状態管理が複雑になる。
      // 　　　呼び出し元の画面の戻るのでpopで良い。
      Navigator.of(context).pop();
    }
  }

  Future sendReceive(SendPort send, data) {
    ReceivePort receivePort = ReceivePort();
    send.send([data, receivePort.sendPort]);
    return receivePort.first;
  }

  //------------------------------
  @override
  Widget build(BuildContext context) {
    // https://stackoverflow.com/questions/50452710/catch-android-back-button-event-on-flutter/50459239#50459239
    // Backボタンを検出して、実行中の場合にアラートを出す。
    return new WillPopScope(
        onWillPop: () {
          print('onWillPop isBusy $isBusy');
          if (isBusy) {
            _showAlert(context, '実行中', '処理が実行中です。');
            return Future.value(false);
          } else {
            // Navigator.of(context).pop(true);
            // Unhandled Exception: Failed assertion: boolean expression must not be null
            // ===> 自分でポップするのではなくtrue/falseを返すのが、正しい仕様。
            // https://cogitas.net/know-user-tapped-back-button-back-navigation-arrow-flutter/
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title == null ? '' : widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //--------------------------------------------
                // WiFi
                Container(
                  padding: const EdgeInsets.all(0.0),
                  // color: Colors.cyanAccent,
                  child:

                  _tryAgain
                      ? RaisedButton(
                      child: Text("WiFi接続確認"),
                      onPressed: () {
                        _checkWifi();
                      })
                      : Text("WiFiに接続されています。"),

                ),

                //--------------------------------------------
                Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: const EdgeInsets.all(0.0),
                      // color: Colors.white,
                      height: 20.0,
                    )),
                //--------------------------------------------
                // ### ステータス・コード
                /*
                Text(
                    statusCounter == null ? '' : statusCounter.toString()
                ),
                */

                // ### 実行中のステータス文字列
                Text(currentStatus != null ? currentStatus : ''),

                // ### プログレスバー
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.greenAccent,
                ),

                // 開始ボタン
                Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                    child: SizedBox(
                      height: 40.0,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        color: (progressValue == 0.0 ? Colors.teal :Colors.red),
                        child: Text(
                            (progressValue == 0.0 ? '開始' : '中止'),
                            style: TextStyle(fontSize: 20.0, color: Colors.white)),
                        onPressed: _onPressedButton,
                      ),
                    )),

                //--------------------------------------------
                Container(
                  color: Colors.red[50],
                  child: Padding(padding: EdgeInsets.all(10.0), child:
                  Text(
                      '''ネットワークに接続して、
データ取得を行います。
                  
実行中は、アプリケーションを表示したまま
端末操作を行わずにお待ちください。'''
                  ),
                  ),),




              ],
            ),
          ),

          // drawer: MyDrawer("Progress"),
          //===> カルテ取得は処理完了または中断まで画面繊維禁止とする。

          /*
      floatingActionButton: new FloatingActionButton(
        onPressed: _onPressedButton,
        tooltip: 'Start Task',
        child: new Icon(Icons.autorenew),
      ),
      */

        ));
  }

}
