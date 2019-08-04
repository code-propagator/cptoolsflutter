import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:cptoolsflutter/line/SingleChartPage.dart';
import 'package:cptoolsflutter/line/LineChart.dart';
import 'package:cptoolsflutter/gui/SyncScroll.dart';

import 'dart:convert' show json;
import 'dart:convert' show utf8;
import 'dart:async';
import 'dart:io';

import 'package:positioned_tap_detector/positioned_tap_detector.dart';

import 'dart:async';

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

import 'package:cptoolsflutter/db/CPTFEntity.dart';

class CPTFMultiChartsPage extends StatefulWidget {
  CPTFMultiChartsPage({
    Key key,
    this.title,
    @required this.isInTabletLayout,
    this.yMaps, // 対象項目のリスト,
    this.dataForSingleChart
  }) : super(key: key);

  final String title;
  final bool isInTabletLayout;

  final LaboTest item = null;

  final List<Map> yMaps; //　表示対象とする検査項目
  final dataForSingleChart;

  @override
  _CPTFMultiChartsPageState createState() => _CPTFMultiChartsPageState();
}

class _CPTFMultiChartsPageState extends State<CPTFMultiChartsPage> {

  @override
  initState() {
    super.initState();

    _syncScroller = SyncScrollController(null);
  }

  Future <String> wait(int milli){
    return Future.delayed( Duration(milliseconds: milli), () async {
      return DateTime.now().toString();
    });
  }

  _handleLabo(Map labo, String userId, int docInfoIdKey) async {
    print('=====> _handleLabo for $userId, $docInfoIdKey');
    String reportStatus = labo['報告状態'] as String;
    String set = labo['セット'] as String;
    String saisyuJST = labo['採取日時'] as String;
    String reportJST = labo['報告日時'] as String;

    List<Map> dt = labo['labeTestListMap'] as List<Map>;

    print('_handleLabo ===============');
    String disp_result = '';
    for (Map dRow in dt) {
      // print(dRow.toString());

      Map<String, dynamic> labomap = {
        fId: null,

        fuserId: userId,//docInfo.accountUserId,
        ffacilityId: dRow["施設ID"],

        fspCode: dRow["材料コード"],
        fspName: dRow["材料名"],
        fitemCode: dRow["項目コード"],
        fitemName: dRow["項目名"],

        fsampleDatetimeJST: dRow["採取日時"],
        fitemValue: dRow["値"],
        fitemUnit: dRow["単位"],
        fitemOut: dRow["異常値判定"],

        fdocInfoIntId: docInfoIdKey// docInfo.Id
      };

      /*print(
          dRow['材料名'].toString() + dRow['項目名'].toString() +
              dRow['値'].toString() + ' ' + dRow['単位'].toString() + ' ' +
              dRow['異常値判定'].toString().replaceAll('基準値範囲内', '')
      );*/

      LaboTest entity = LaboTest.fromMap(labomap);
      //  print(' ====> Saving LaboTest entity to appdb: ' + entity.toMap().toString());

      /*LaboTest savedLabo = await Provider.of<MyAppInfo>(context).appdb.saveLaboTest(entity) as LaboTest;
      if (savedLabo != null) {
        print('SAVED');
      } else {
        print('NOT SAVED');
      }*/
    }
    print('===============');

  }

  // double VERTICAL_ITEM_HEIGHT = 80.0;
  //ScrollController _controller = new ScrollController();

  void _goToElement(int index){
    // #### チャート一覧では、自動スクロールを抑止しておく。
    /*

    print('goToElement $index');

    if (index < 0)  return;

    try {
      _controller.animateTo(
          VERTICAL_ITEM_HEIGHT * (index > 0 ? (index) : 0),
          // 100 is the height of container and index of 6th element is 5
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    } catch (e) {

    }

    */
  }


  //------------------------------------------
  // https://pub.dev/packages/positioned_tap_detector#-installing-tab-
  String _gesture = "";
  TapPosition _position = TapPosition(Offset.zero, Offset.zero);
  void _onTap(TapPosition position) => _updateState('single tap', position);

  void _onDoubleTap(TapPosition position) =>
      _updateState('double tap', position);

  void _onLongPress(TapPosition position) =>
      _updateState('long press', position);

  void _updateState(String gesture, TapPosition position) {
    setState(() {
      _gesture = gesture;
      _position = position;
    });
  }

  String _formatOffset(Offset offset) =>
      "${offset.dx.toStringAsFixed(1)}, ${offset.dy.toStringAsFixed(1)}";
  //------------------------------------------

  // 初回に与えられたLaboTestのリスト中でのインデックス
  int firstTargetItemIndex = -1;
  // 選択場が変わったときのインデックス
  int currentSelectedIndex = -1;

  List<LaboTest> laboTestEntityList;
  List<ChartData> laboTestChartDataList;

  CPTFChartContainerState _chartContainerStateReference = null;

  scrollChartToIndex(int index) {
    if (_chartContainerStateReference != null) {
      _chartContainerStateReference.scrollToItem(index);
    }
  }

  scrollChartToEnd() {
    if (_chartContainerStateReference != null) {
      _chartContainerStateReference.scrollToEnd();
    }
  }

  // ChartContaineにコールバック関数を引数で渡す。アンダースコア必須

  _chartSelectionChanged(CPTFChartContainerState chartContainerState, int indexInChart, var obj) {

    _chartContainerStateReference = chartContainerState;

    print('_chartSelectionChanged $indexInChart');
    print('obj');
    print(obj);

    // チャートから選択が変わったとの知らせがきたので、
    // リストに反映したいが、ここでsetTextを呼び出すと
    // 画面全体の作り直しになってしまう。
    // setState(() {
    currentSelectedIndex = indexInChart;
    // });

    _goToElement(currentSelectedIndex);
  }

  /*
  _scrollNotificationHandler(ScrollNotification notif, ScrollController scroll) {
    _syncScroller.processNotification(notif, scroll);
  }
  */

  // List<Map> _pivotYList = List<Map>();


  Future<Widget> _getData(BuildContext context) async {
    print('_getData');

    // エラー表示をしたい時にExceptionを発生させることもできる。
    // throw new Exception("文書内容が見つかりませんでした。");

    await wait(200);

    String userId = null;

    /*
    // ###
    // アカウント
    Account account = await Provider.of<MyAppInfo>(context).appdb.selectFirstAccount() as Account;

    try {
      userId = account.UserId;
    } catch (e) {

    }


    if (userId == null) {
      return Container(
          padding: EdgeInsets.all(4.0),
          child: Center(
              child: Column(
                  children: <Widget>[
                    Text('ユーザIDが不明です。アカウント設定を確認して下さい。')
                  ])));
    }
    */

    // ####################################
    // ===> ピボットY軸（項目一覧の取得）

    List<Map> yMaps = null;
    if (widget.yMaps != null) {

      // 項目指定があった
      yMaps = widget.yMaps;

    } else {

      yMaps = List<Map>();

      /*
      // 項目指定がなかったので、データベースから全てを取得する
      // ユーザのすべてのピボットY軸項目
      yMaps = await Provider
          .of<MyAppInfo>(context)
          .appdb
          .selectLaboTestPivotY(userId) as List<Map>;
      */
    }

    //#####################################

    List<Container> chartContainerList = List<Container>();
    // List<ScrollController> scrollControllerList = List<ScrollController>();
    // _pivotYList.clear();

    int c = 0;
    Map distinctX = Map();// 重複なしのX軸の出現値（日付）リストが欲しいので、辞書のキーを利用して求めることにする。

    // Y軸
    for (Map yMap in yMaps) {
      // print(yMap.toString());
      // flutter: {facilityId: 1.2.840.114319.5.1000.1.26.1, spCode: 010, itemCode: 0474130, spName: 血液, itemName: #C(ﾋﾟｰｸ出現時間), itemUnit: [分’秒]}
      // flutter: {facilityId: 1.2.840.114319.5.1000.1.26.1, spCode: 010, itemCode: 0474140, spName: 血液, itemName: #C(ﾋﾟｰｸ面積値), itemUnit: }

      // _pivotYList.add(yMap);

      // １つのピボットY項目に対して、時系列データを取得する。
      // ===> ピボットX軸項目すべてにOUTER JOINTなどしていないので、単純にデータベースに存在するレコードのみを取得する。
      List<Map> maps;
      /*
      maps = await Provider.of<MyAppInfo>(context).appdb.selectLaboTestPivotRow(
          userId,
          yMap[ffacilityId] as String,
          yMap[fspCode] as String,
          yMap[fitemCode] as String,
          yMap[fspName] as String,
          yMap[fitemName] as String,
          yMap[fitemUnit] as String
      ) as List<Map>;
      */

      String chartTitle = (yMap[fspName] as String) + ' ' + (yMap[fitemName] as String) + ' ' + (yMap[fitemUnit] as String);
      print('$c: ' + chartTitle);

      if (widget.dataForSingleChart != null) {
        maps = await widget.dataForSingleChart(c, yMap) as List<Map>;
      }

      if (maps != null && maps.length > 0) {

        int addIndex = 0;
        ChartData cd = null;

        // LaboTestの時系列を作る
        List<ChartData> laboTestChartDataList = List<ChartData>();
        // List<LaboTest> laboTestEntityList = List<LaboTest>();
        // X軸
        for (Map map in maps) {

          // print('add');
          LaboTest labo = LaboTest.fromMap(map);
          // X, Y
          String jst = labo.sampleDatetimeJST;
          String itemValue = labo.itemValue;
          print(jst + ' ' + itemValue);

          // distinctX[jst] = jst;
          // ====> X軸表示用の文字列（日付）は以下でフォーマットしてxstrにするので、
          //       distinctXにはjstではなくxstrを使わなければならない。

          //------------
          // ChartData

          // 付加情報

          String dispItemOut = labo.itemOut == '基準値範囲内' ? '' : labo.itemOut;

          Color pointColor = Colors.grey[700];

          Color textColor = Colors.black;
          if (labo.itemOut == '上限値超え') {
            textColor = Colors.red[900];
            pointColor = Colors.red;
          } else if (labo.itemOut == '下限値未満') {
            textColor = Colors.blue[900];
            pointColor = Colors.blue;
          }

          Color cardColor = Colors.white;
          if (labo.itemOut == '上限値超え') {
            cardColor = Colors.red[50];
          } else if (labo.itemOut == '下限値未満') {
            cardColor = Colors.blue[50];
          }

          String xstr = jst;
          if (jst != null && jst.length >= 19) {
            //###### 同日で異なる時刻に結果が入っている場合があるので注意
            //===> 例）2014/1/29 16:53 スクリーニング (文書1/29発行)
            //        2014/1/29 15:45 緊急検査室１　(文書1/30発行）
            //
            // yy/MM/dd HH:mm
            //##### チャート表示で同日に２点存在しないように（１点が消える）、時刻までの区別は必須。
            xstr = jst.substring(2, 4) + '/' + jst.substring(5,7) + '/' + jst.substring(8, 10)
                + ' ' + jst.substring(11,19);
          }

          // #########
          // X軸の統合用辞書（フォーマット済みの表示文字列を使う）
          // yy/MM/dd HH:mm:ss
          distinctX[xstr] = xstr;
          // #########

          cd = ChartData(
              xstr,
              null
          ).setInfo(pointColor);
          try {
            double num = double.parse(itemValue);
            // print('---> is num? ---> $num');
            cd.y = num;

          } catch (e) {
            // print('to num error');

            cd.y = null;
          }
          laboTestChartDataList.add(cd);
          //------------

          // laboTestEntityList.add(labo);

          addIndex++;
        }

        // ##################
        // チャート１つ分のデータが揃った

        //----
        // チャートのタイトルの高さ
        double CHART_TITLE_HEIGHT = 28.0;

        // チャート全体（タイトル、目盛など含む）の高さ
        // 日付文字列を９０度回転しているので大きめにする。
        double CHART_CONTAINER_HEIGHT = 220.0;

        // チャートの折れ線などの描画エリア(CustomPaint)の高さ
        double CHART_HEIGHT = 120.0;
        // ===> CHART_CONTAINER_HEIGHTからCHART_HEIGHTを引いた高さが、
        //      X軸のTicks文字列エリアに使われる

        double CHART_AXIS_Y_LABEL_WIDTH = 50.0;
        // Y軸の文字表示幅
        //----

        // ScrollController scroll = ScrollController();

        Container singleChart = Container(
            height: CHART_CONTAINER_HEIGHT,// 必須
            margin: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
            // 枠線
            /*
          decoration: BoxDecoration(
            border: new Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          */
            child: CPTFChartContainer(
                laboTestChartDataList,// _debugChartList,
                chartTitle,
                CHART_TITLE_HEIGHT,
                CHART_CONTAINER_HEIGHT,
                CHART_HEIGHT,
                CHART_AXIS_Y_LABEL_WIDTH,
                -1,//currentSelectedIndex,
                null, // _chartSelectionChanged // #### --- コールバック抑止,
                // ####
                _switchValue == true ? fullXProviderFunc : null,
                null/*scroll*/, _syncScroller/*_scrollNotificationHandler*/
            )
        );

        chartContainerList.add(singleChart);
        //scrollControllerList.add(scroll);
        // _syncScroller.registerScrollController(scroll);
        // ##################

      }

      c++;
    } // EOF　Y軸

    // ### X軸（日付）をマージする場合のために出現値のリストを作る
    fullX.clear();
    print('distinctX');
    print(distinctX);

    if (distinctX.length > 0) {
      // keyはdynamicからStringにキャストする
      distinctX.keys.forEach((key) {
        fullX.add(key.toString());
      });

      fullX.sort((a,b) => a.toString().compareTo(b.toString()));

      print('FULL X');
      print(fullX.length);
      print(fullX.toString());
    }

    // _syncScroller = SyncScrollController(scrollControllerList);



    //--------------------------------------------------------------------------
    // チャートのリストを表示する
    if (chartContainerList.length as int > 0) {

      return Container(
          padding: EdgeInsets.all(1.0),
          child: Center(
              child: Column(
                  children: <Widget>[

                    Container(child:Text('※赤：上限値超え、青：下限値未満　※数値化できない結果値はプロットされません。', style: TextStyle(fontSize: 12.0),)),

                    /*
                    Switch(
                      value: _switchValue,
                      onChanged: (value) {
                      setState(() {
                          _switchValue = value;
                        });
                      },
                    ),
                    */


                    Container(height:44.0, child:
                    SwitchListTile(
                      title: const Text('時間軸を統合'),
                      value: _switchValue,
                      onChanged: (value) {
                        setState(() {
                          _switchValue = value;
                        });
                      },
                      secondary: const Icon(Icons.timeline)
                    )),


                    Expanded(child:ListView.builder(
                        itemCount: chartContainerList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return chartContainerList[index];
                        })
                    ),

                  ]
              )
          )
      );

    } else {

      return Container(
          padding: EdgeInsets.all(4.0),
          child: Center(
              child: Column(
                  children: <Widget>[
                    Text('データがありません。')
                  ])));

    }
    //--------------------------------------------------------------------------

  }

  // 時間軸を統合する
  // #### 異なる文書でも同日同時刻の検査結果が入ってくる場合がある。
  // #### スクリーニングと緊急検査室
  // ####
  // #### 時間軸の統合では、複数のチャート項目の時間軸をマージするとともに、
  // #### １つの項目についても、時間軸のマージが行われる後の項目がペイント位置オフセット計算で出てくる）
  bool _switchValue = true;

  List<String> fullX = List<String>();

  fullXProviderFunc () {
    return fullX;
  }

  SyncScrollController _syncScroller;

  @override
  Widget build(BuildContext context) {
    // FutureBuilderによって_getDataで描画

    FutureBuilder futureBuilder = FutureBuilder<Widget>(
      future:_getData(context), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            {
              // return Text('Press button to start.');
              return Text('');
            }
          case ConnectionState.active:
          case ConnectionState.waiting:
            {
              // データ取得待ち
              // return Text('Awaiting result...');
              return CircularProgressIndicator(strokeWidth: 1.0);
            }

          case ConnectionState.done:
            {
              if (snapshot.hasError) {
                // return Text('Error: ${snapshot.error}');
                String  err = snapshot.error.toString().replaceAll('Exception:', '');
                return Text(err.toString());
              }

              // return Text('Result: ${snapshot.data}');

              return snapshot.data;

            }
        }
        return null; // unreachable
      },
    );

    if (widget.isInTabletLayout) {
      return Center(child: futureBuilder);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.title == null ? '' : widget.title
        ),
      ),
      body: Center(child: futureBuilder),
      /*floatingActionButton: new FloatingActionButton(
        onPressed: () {

          _goToElement(currentSelectedIndex);
          scrollChartToIndex(currentSelectedIndex);

        },
        child: new Icon(Icons.refresh),
      ),*/
    );
  }
}
