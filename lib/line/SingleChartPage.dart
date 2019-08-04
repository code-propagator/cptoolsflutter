import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'dart:convert' show json;
import 'dart:convert' show json;
import 'dart:convert' show utf8;
import 'dart:async';
import 'dart:io';

import 'package:positioned_tap_detector/positioned_tap_detector.dart';

import 'package:cptoolsflutter/line/LineChart.dart';

import 'dart:async';

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

class MyTextHeader extends StatefulWidget {
  MyTextHeader({Key key, this.title, this.sub, this.state, this.fontColor, this.item}) : super(key: key);

  final String title;
  final String sub;
  final Color fontColor;

  final item;// Entity

  final CPTFSingleChartPageState state;

  @override
  MyTextHeaderState createState() => MyTextHeaderState();

}

class MyTextHeaderState extends State<MyTextHeader> {
  String _title;
  String _sub;
  dynamic _item;// Entity

  @override
  void initState() {
    super.initState();

    _title = widget.title;
    _sub = widget.sub;
    _item = widget.item;

    // ### connect to parent page's state
    widget.state.textHeaderStateRef = this;
  }

  updateHeader(String title, String sub, dynamic item) {
    setState(() {
      _title = title;
      _sub = sub;
      _item = item;
    });
  }

  dynamic getItem () {
    return _item;
  }

  @override
  build(BuildContext context) {
    return Column(children: <Widget>[
      Text(_title, style: TextStyle(color: widget.fontColor)),
      Text(_sub, style: TextStyle(color: widget.fontColor)),
    ]);
  }
}

//------------------------------------------------------------------------------

class CPTFSingleChartPage extends StatefulWidget {
  CPTFSingleChartPage({
    Key key,
    this.title,
    @required this.isInTabletLayout,
    @required this.item,
    this.listAroundItem
  }) : super(key: key);

  final String title;
  final bool isInTabletLayout;
  final LaboTest item;
  final listAroundItem;// List<Map>

  @override
  CPTFSingleChartPageState createState() => CPTFSingleChartPageState();
}

class CPTFSingleChartPageState extends State<CPTFSingleChartPage> {

  Future <String> wait(int milli){
    return Future.delayed( Duration(milliseconds: milli), () async {
      return DateTime.now().toString();
    });
  }

  /*
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
  */


  double VERTICAL_ITEM_HEIGHT = 70.0;

  ScrollController _controller = new ScrollController();

  void _goToElement(int index){

    print('goToElement $index');


    _controller.animateTo(
        VERTICAL_ITEM_HEIGHT * (index > 0 ? (index) : 0), // 100 is the height of container and index of 6th element is 5
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);

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

  LaboTest _entityAtIndex(int index) {
    LaboTest entity = null;

    if (_switchValue == true) {
      print("=======");
      String key = fullX[index];
      print(key);// 07/10/29 00:00:01
      print(distinctX[key]);

      for (int j = 0; j < laboTestEntityList.length; j++) {
        LaboTest labo = laboTestEntityList[j];
        String jst = labo.sampleDatetimeJST;
        String xstr = jst.substring(2, 4) + '/' + jst.substring(5, 7) +
            '/' + jst.substring(8, 10)
            + ' ' + jst.substring(11, 19);

        if (xstr == key) {
          print('xstr == key');
          print(labo.toMap().toString());
          entity = labo;

          //####
          // breakせず、後から見つかった方を採用する
          //####
        } else {
          continue;
        }
      }
    } else {
      entity = laboTestEntityList[index];
    }

    return entity;
  }

  // ChartContaineにコールバック関数を引数で渡す。アンダースコア必須

  _chartSelectionChanged(CPTFChartContainerState chartContainerState, int indexInChart, var obj) {

    _chartContainerStateReference = chartContainerState;

    print('_chartSelectionChanged $indexInChart');

    print('obj');
    if (obj != null) {
      print(obj);
      print(obj.x);
      print(obj.y);
      print(obj.info);
      /*
    flutter: Instance of 'ChartData'
    flutter: 08/04/22 00:00:01
    flutter: 0.40000000000000036
    flutter: Color(0xff616161)
     */



    }

    // チャートから選択が変わったとの知らせがきたので、
    // リストに反映したいが、ここでsetTextを呼び出すと
    // 画面全体の作り直しになってしまう。
    // setState(() {
    currentSelectedIndex = indexInChart;
    // });
    // ===> MyTextHeader部品のみを再描画させる。
    if (textHeaderStateRef != null) {
      try {

        //#######
        //####### 縮退表示なのか、そのまま表示なのかによって、エンティティは異なる。
        //#######
        LaboTest entity = _entityAtIndex(currentSelectedIndex);

        String title = null;
        String sub = null;
        if (entity != null) {
          title = entity.spName + ' ' + entity.itemName + ' ' + entity.itemValue +
              ' ' + entity.itemUnit;
          sub = entity.sampleDatetimeJST;
        }

        if (title != null && sub != null) {
          textHeaderStateRef.updateHeader(title, sub, entity);
        }

      } catch (e) {

      }
    }

    _goToElement(currentSelectedIndex);
  }

  MyTextHeaderState textHeaderStateRef;


  // 時間軸を統合する
  // #### 異なる文書でも同日同時刻の検査結果が入ってくる場合がある。
  // #### スクリーニングと緊急検査室
  // ####
  // #### 時間軸の統合では、複数のチャート項目の時間軸をマージするとともに、
  // #### １つの項目についても、時間軸のマージが行われる後の項目がペイント位置オフセット計算で出てくる）
  bool _switchValue = false;

  Map distinctX = Map();

  List<String> fullX = List<String>();

  fullXProviderFunc () {
    return fullX;
  }


  Future<List<Map>> _getListAroundItem() async {
    if (widget.listAroundItem != null) {
      return await widget.listAroundItem(widget.item) as List<Map>;
    } else {
      return List<Map>();
    }
  }

  Future<Widget> _getData(BuildContext context) async {

    // エラー表示をしたい時にExceptionを発生させることもできる。
    // throw new Exception("文書内容が見つかりませんでした。");

    await wait(200);

    String title = '';
    String sub = '';
    String chartTitle = '';
    String text = '';

    LaboTest entity = widget.item as LaboTest;
    if (entity != null) {

      try {
        title = entity.spName + ' ' + entity.itemName + ' ' + entity.itemValue + ' ' + entity.itemUnit;
        chartTitle = entity.spName + ' ' + entity.itemName + ' ' + entity.itemUnit;
        sub = widget.item.sampleDatetimeJST;
      } catch (e) {

      }
    }

    // ### 現在のLaboTestと同じ検査項目の時系列データList<LaboTest>をデータベースから取得する。
    laboTestEntityList = List<LaboTest>();
    laboTestChartDataList = List<ChartData>();

    distinctX = Map();// 重複なしのX軸の出現値（日付）リストが欲しいので、辞書のキーを利用して求めることにする。

    try {

      List<Map> maps = await _getListAroundItem() as List<Map>;

      if (maps != null && maps.length > 0) {

        int addIndex = 0;
        int addLen = maps.length;
        ChartData cd = null;

        for (Map map in maps) {
          print('addIndex $addIndex of $addLen');
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
            // yy/MM/dd HH:mm:ss
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
              null).setInfo(pointColor);
          try {
            double num = double.parse(itemValue);
            print('---> is num? ---> $num');
            cd.y = num;

          } catch (e) {
            print('to num error');

            cd.y = null;
          }
          laboTestChartDataList.add(cd);
          //------------

          laboTestEntityList.add(labo);

          //--------------
          // 検索条件に指定したLaboTest entityはリスト中のどこにあるか？
          /*entity.userId,
          entity.facilityId,
          entity.spCode,
          entity.itemCode,
          entity.spName,
          entity.itemName,
          entity.itemUnit*/


          /*print(entity.sampleDatetimeJST  + ' ??? ' + labo.sampleDatetimeJST);
          if (entity.sampleDatetimeJST == labo.sampleDatetimeJST) {
            print('===> ###### $addIndex');
            currentSelectedIndex = addIndex;
          }*/

          // #### 日付（横軸）は重複する場合があるので、
          // #### エンティティのオブジェクトレベルで比較が必要。
          if (entity.toMap().toString() == labo.toMap().toString()) {
            firstTargetItemIndex = addIndex;
          }

          //--------------

          addIndex++;
        }
      }
    } catch (e) {
      print(e);
    }

    currentSelectedIndex = firstTargetItemIndex;

    int displayListCount = laboTestEntityList.length;
    if (_switchValue == true) {
      displayListCount = fullX.length;
    } else {
      displayListCount = laboTestEntityList.length;
    }

    // 表示用のWidgetを生成する。

    final TextTheme textTheme = Theme.of(context).textTheme;

    bool dispText = false;

    //----
    // チャートのタイトルの高さ
    double CHART_TITLE_HEIGHT = 28.0;

    // チャート全体（タイトル、目盛など含む）の高さ
    // 日付文字列を９０度回転しているので大きめにする。
    double CHART_CONTAINER_HEIGHT = 250.0;

    // チャートの折れ線などの描画エリア(CustomPaint)の高さ
    double CHART_HEIGHT = 150.0;
    // ===> CHART_CONTAINER_HEIGHTからCHART_HEIGHTを引いた高さが、
    //      X軸のTicks文字列エリアに使われる

    double CHART_AXIS_Y_LABEL_WIDTH = 50.0;
    // Y軸の文字表示幅
    //----

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

    return Container(
        padding: EdgeInsets.all(4.0),
        child: Center(
          child: Column(
            children: <Widget>[
              // new Text('Countries', style: new TextStyle(fontWeight: FontWeight.bold),),
              // Text(title, style: textTheme.headline),
              // Text(sub, style: textTheme.subhead,),

              // Text(title, style: TextStyle(fontSize: 18.0)),
              // Text(sub, style: TextStyle(fontSize: 14.0)),
              // MyTextHeader(title: title, sub:sub, state:this),



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



              // チャート
              // SizedBox(height:CHART_CONTAINER_HEIGHT + 10,
              // ===> Landscapeにしたとき、Expandedはうまくいくが、SizedBoxでは画面途切れによるエラーが発生する。
              Expanded(flex: 2, child:
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,// flutter: Vertical viewport was given unbounded height.
                // controller: _controller,
                children: <Widget>[
                  Text('※赤：上限値超え、青：下限値未満　※数値化できない結果値はプロットされません。', style: TextStyle(fontSize: 12.0),),
                  // 初期選択指定は取りやめ。縮退表示をするとずれが生じる。
                  //Text('※赤：上限値超え、青：下限値未満　※黄色は画面遷移元の採取日時に対応　※数値化できない結果値はプロットされません。', style: TextStyle(fontSize: 12.0),),

                  Container(
                      color: Colors.grey[100],
                      height: CHART_CONTAINER_HEIGHT,// 必須
                      margin: const EdgeInsets.all(10.0),
                      // 枠線
                      /*
                        decoration: BoxDecoration(
                          border: new Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        */
                      child: CPTFChartContainer(
                          laboTestChartDataList,
                          chartTitle,
                          CHART_TITLE_HEIGHT,
                          CHART_CONTAINER_HEIGHT,
                          CHART_HEIGHT,
                          CHART_AXIS_Y_LABEL_WIDTH,
                          currentSelectedIndex,
                          _chartSelectionChanged,
                          // ####
                          _switchValue == true ? fullXProviderFunc : null,
                          null, null
                      )
                  ),

                  /*
                      // タップした座標の検出
                      Column(children: <Widget>[
                        Container(
                          height: CHART_CONTAINER_HEIGHT,// 必須
                          margin: const EdgeInsets.all(10.0),
                          child:
                          PositionedTapDetector(
                            onTap: _onTap,
                            onDoubleTap: _onDoubleTap,
                            onLongPress: _onLongPress,
                            child: Container(
                              width: 160.0,
                              height: 160.0,
                              color: Colors.redAccent,
                            ),
                          ),),
                        Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Text("Gesture: $_gesture\n"
                              "Global: ${_formatOffset(_position.global)}\n"
                              "Relative: ${_formatOffset(_position.relative)}"),
                        ),
                      ],

                      ),

                      */


                  // 文書移動ボタン
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        RaisedButton(
                          elevation: 5.0,
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                          padding: EdgeInsets.all(5.0),
                          color: Colors.teal,
                          child: MyTextHeader(
                              title: title,
                              sub:sub,
                              state:this,
                              fontColor: Colors.white,// Text('選択項目の文書を表示', style: TextStyle(color: Colors.white)),
                              item: entity // LaboTestを渡しておく。
                          ),
                          onPressed: () async {
                            print('GO TO DOCUMENT FOR SELECTED ITEM $currentSelectedIndex');

                            LaboTest entity = null;//_entityAtIndex(currentSelectedIndex);


                            //--------------------------
                            /*
                            try {
                              entity = laboTestEntityList[currentSelectedIndex];
                            } catch (e) {
                              entity = null;
                            }
                            */
                            // ===> currentSelectedIndexからではなく、MyTextHeaderから取り出す。
                            entity = textHeaderStateRef.getItem();
                            //
                            //--------------------------

                            if (entity == null) return;

                            print(entity.toMap().toString());



                            // ナビゲーションのpopで「カルテ表示」画面に戻る.
                            // Navigator.of(context).pop(entity);

                            /*
                            Map map = await Provider.of<MyAppInfo>(context).appdb.selectDocInfoById(
                                entity.docInfoIntId
                            ) as Map;

                            if (map == null) return;

                            // ### 文書詳細表示画面をプッシュして表示する。
                            MyItemData tmp = null;

                            DocInfo obj = DocInfo.fromMap(map);
                            print('obj.Id = ' + obj.Id.toString());

                            tmp = MyItemData();
                            tmp.title = (obj != null ? (obj.title != null ? obj.title : '') : '');
                            tmp.subtitle = (obj != null
                                ? (obj.confirmDateJST != null ? obj.confirmDateJST : '')
                                : '');
                            tmp.docInfo = obj;

                            // ### 指定した文書の詳細表示をプッシュする。
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return ItemDetails(
                                    isInTabletLayout: false,
                                    item: tmp, // <--- MyItemData
                                  );
                                },
                              ),
                            );

                            */


                          },
                        ),
                      ]),

                ],
              )
              )
              ,

              /*Listview diplay rows for different widgets,
                Listview.builder automatically builds its child widgets with a
                template and a list*/

              // 項目リスト

              Expanded(flex: 2, child:
              ListView.builder(
                  controller: _controller,
                  itemCount: displayListCount,
                  itemBuilder: (BuildContext context, int index){

                    if (index == 0 && dispText) {
                      return Text(text);
                    }

                    // LaboTest laboEntity = laboTestEntityList[index] as LaboTest;
                    LaboTest laboEntity = _entityAtIndex(index);

                    String dispItemOut = laboEntity.itemOut == '基準値範囲内' ? '' : laboEntity.itemOut;

                    Color textColor = Colors.black;
                    if (laboEntity.itemOut == '上限値超え') {
                      textColor = Colors.red[900];
                    } else if (laboEntity.itemOut == '下限値未満') {
                      textColor = Colors.blue[900];
                    }

                    Color cardColor = Colors.white;
                    if (laboEntity.itemOut == '上限値超え') {
                      cardColor = Colors.red[50];
                    } else if (laboEntity.itemOut == '下限値未満') {
                      cardColor = Colors.blue[50];
                    }

                    if (firstTargetItemIndex == index ) {
                      cardColor = Colors.yellow;
                    }

                    return GestureDetector(
                        onTap: () {
                          print('tapped on list item $index');

                          LaboTest clickedEntity = _entityAtIndex(index);
                          print('---->');
                          print(clickedEntity.toMap().toString());

                          // setStateでは画面全体の再描画が起こり、
                          // _getDataによる全面再構成となってしまう。
                          // MyAppInfoなどを使っていないため、項目の選択状態など内部状態を再現できない。
                          // setState(() {
                            currentSelectedIndex = index;
                          // });
                          // ===>　リスト項目をクリックした場合に「再描画」したい部分だけMyTextHeader(StatefulWidget)として部品にして、
                          //       MyTextHeaderStateとLaboTextChartPageStateの参照関係を確立する。
                          // ===> MyTextHeaderStateのみで、setStateが起こるので、部分的に画面の一部を更新できる。
                          if (textHeaderStateRef != null) {
                            try {
                              LaboTest entity = laboTestEntityList[currentSelectedIndex];
                              String title = entity.spName + ' ' + entity.itemName + ' ' + entity.itemValue + ' ' + entity.itemUnit;
                              String sub = entity.sampleDatetimeJST;

                              textHeaderStateRef.updateHeader(title, sub, entity);

                            } catch (e) {

                            }
                          }

                          scrollChartToIndex(currentSelectedIndex);

                        },
                        //---------------------------------------
                        child: // Card(
                            // color: cardColor,
                            // child:
                            Container(
                              color: cardColor,
                                height:VERTICAL_ITEM_HEIGHT, child: // ### 自動スクロールのためCanvasで高さを固定する。
                              //Padding(padding: const EdgeInsets.all(8.0),child:
                                Row(children: <Widget>[

                                  // column1
                                  Expanded(child:Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // ### 時系列表示をするので、項目名はすべて同じ。===> 採取日時を出力する。
                                        Text('', style: TextStyle(fontSize:10.0, color: textColor)),
                                        Text(laboEntity.sampleDatetimeJST, style: TextStyle(fontSize:16.0, color: textColor)),

                                      ]
                                  )),

                                  // column1
                                  Expanded(child:Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(dispItemOut, style: TextStyle(fontSize:12.0, color: textColor)),
                                        Text(laboEntity.itemValue + ' ' + laboEntity.itemUnit, style: TextStyle(fontSize:16.0, color: textColor)),


                                      ]
                                  )),
                                  /*
                                // column1
                                Expanded(child:Column(
                                    children: <Widget>[
                                      Text('title', style: TextStyle(fontSize:10.0)),
                                      Text('subtitle', style: TextStyle(fontSize:6.0)),
                                    ]
                                )),
                                */

                                ])
                            //)
                          )
                        // )
                      //---------------------------------------
                    );
                  }
              )
              )




              /*
                SingleChildScrollView(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(title, style: textTheme.headline),
                    // Text(sub, style: textTheme.subhead,),
                    Text(text, style: TextStyle(fontSize: 16.0)),
                  ],
                ))
                */
            ],
          ),
        )
    );

    /*
    return SingleChildScrollView(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: textTheme.headline),
        Text(sub, style: textTheme.subhead,),
        Text(text, style: TextStyle(fontSize: 16.0)),
      ],
    ));
    */

  }

  @override
  Widget build(BuildContext context) {

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
              widget.item.spName + ' ' + widget.item.itemName + ' ' + widget.item.itemUnit
          ),

          /*
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.bookmark),
              // color: Colors.grey[500],
              onPressed: _bookmarkThis,
            ),
          ]

          */
      ),
      body: Center(child: futureBuilder),


      /*
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _goToElement(currentSelectedIndex);
          scrollChartToIndex(currentSelectedIndex);

        },
        child: new Icon(Icons.refresh),
      ),
      */

    );
  }
// user defined function
  void _showDialog(String title, String _text) {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: new Text(title),
        content: new Text(_text),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /*

  _bookmarkThis() async {
    if (widget.item == null) return;

    LaboTest labo = widget.item as LaboTest;
    if (labo == null) return;

    String laboJSONString = json.encode(labo.toMap()) as String;


    Bookmark entity = Bookmark();
    entity.userId = labo.userId;
    entity.itemLabel = 'LaboTest_for_Chart';
    entity.contents = laboJSONString;

    int d = await Provider.of<MyAppInfo>(context).appdb.deleteBookmark(entity) as int;
    print(d);

    Bookmark saved = await Provider.of<MyAppInfo>(context).appdb.saveBookmark(entity) as Bookmark;
    if (saved == null) {
      return;
    } else {
      print('item is saved to bookmark' + saved.toMap().toString());
      _showDialog('ブックマーク', 'ブックマークに登録しました。');
    }
  }
  */
}
